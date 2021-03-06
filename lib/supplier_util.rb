# encoding: utf-8
class SupplierUtil

  def supplier_logger
    @supplier_logger ||= Logger.new("#{Rails.root}/log/supplier_import_#{DateTime.now.to_s.gsub(":","-")}.log")
  end

  def parse_line(line)
    data = {}
    line_array = line.split(@csv_parse_options[:col_sep])
    @field_mapping.each do |k,v|
      value = v.nil? ? nil : line_array[v]
      data[k] = value
    end
    return data
  end

  def overwrite_field(item, field, data)
    unless (data.blank? or data == item.send(field))
      item.send "#{field}=", data
    end
  end

  def populate_field(item, field, data)
    overwrite_field(item, field, data) if item.send(field).blank?
  end

  def update_supply_item(supply_item, data)
    overwrite_field(supply_item, "purchase_price", data[:price_excluding_vat].to_s.gsub(",",".")) unless data[:price_excluding_vat].to_f == 0
    overwrite_field(supply_item, "stock", data[:stock_level].gsub("'","").to_i)
    overwrite_field(supply_item, "weight", data[:weight].gsub(",",".").to_f)
    overwrite_field(supply_item, "manufacturer", data[:manufacturer])
    overwrite_field(supply_item, "manufacturer_product_code", data[:manufacturer_product_code])
    overwrite_field(supply_item, "image_url", "#{data[:image_url]}")
    overwrite_field(supply_item, "pdf_url", "#{data[:pdf_url]}")
    overwrite_field(supply_item, "category01", "#{data[:category01]}")
    overwrite_field(supply_item, "category02", "#{data[:category02]}")
    overwrite_field(supply_item, "category03", "#{data[:category03]}")

    unless supply_item.changes.empty?
      changes = supply_item.changes
      if supply_item.save
        supplier_logger.info("[#{DateTime.now.to_s}] SupplyItem change: #{supply_item.to_s}:  #{changes.inspect}")
      else
        supplier_logger.error("[#{DateTime.now.to_s}] Supply item change FAILED: #{supply_item.to_s}: #{supply_item.changes.inspect}. Errors: #{supply_item.errors.full_messages}")
      end
    else
      supplier_logger.info("[#{DateTime.now.to_s}] SupplyItem identical, thus not changed: #{supply_item.to_s}")
    end
  end


  # Goes through the existing supply items in the system, then tries to find each
  # of them in the supplier CSV file. If that fails, the item is marked as deleted locally.
  # If the item is there, we read the updated product information from the CSV file and update the
  # supply item and its related products.
  def update_supply_items(filename = self.import_filename)
    affected_items = @supplier.products.supplied.collect(&:supply_item)
    affected_supplier_product_codes = affected_items.collect(&:supplier_product_code)
    item_hashes = []
    file = File.open(filename, "r")
    file.each do |line|
      data = parse_line(line)
      next if data[:supplier_product_code].blank? # The line is incomplete, skip it
      if affected_supplier_product_codes.include?(data[:supplier_product_code])
        item_hashes << data
      end
    end
    file.close
    found_supplier_product_codes = item_hashes.collect{|h| h[:supplier_product_code]}

    SupplyItem.expire_category_tree_cache(@supplier)
    #Update the local supply items information using the line from the CSV file
    SupplyItem.suspended_delta do
      # Deactivate the supply item if the line's not there anymore
      to_delete = affected_supplier_product_codes - found_supplier_product_codes
      to_delete.each do |td|
        supply_item = @supplier.supply_items.where(:supplier_product_code => td).first
        supply_item.status_constant = SupplyItem::DELETED
        if supply_item.save
          supplier_logger.info("[#{DateTime.now.to_s}] Marked Supply Item as deleted: #{supply_item.to_s}")
        end
      end

      item_hashes.each do |data|
        supply_item = @supplier.supply_items.where(:supplier_product_code => data[:supplier_product_code]).first
        update_supply_item(supply_item, data)
      end
    end
  end

  # The updates array needs to be in the form [ [supplier_product_code1, stock_level],
  #                                             [supplier_product_code2, stock_level]]
  # The updates array must be set up in a method in the descending class (e.g. AlltronUtil)
  def quick_update_stock(filename)
    SupplyItem.suspended_delta do
      @updates.each do |upd|
        si = @supplier.supply_items.where(:supplier_product_code => upd[0]).first
        unless si.nil?
          if si.update_attributes(:stock => upd[1]) == true
            supplier_logger.info("[#{DateTime.now.to_s}] Quick stock update: #{si.to_s} now #{si.stock}")
          else
            supplier_logger.error("[#{DateTime.now.to_s}] Quick stock update failed: #{si.to_s}, errors:  #{si.errors.full_messages}")
          end
        end
      end
    end
  end


  # Import supply items from a supplier-provided CSV file, but only if they're
  # not present in our system yet.
  def import_supply_items(filename = self.import_filename)
    # before calling this in a descended class, you must set up these variables:
    # @supplier = The supplier to import for (an AR object)
    SupplyItem.expire_category_tree_cache(@supplier)

    SupplyItem.suspended_delta do
      File.open(filename, "r").each_with_index do |line, i|
        next if i == 0 # We skip the first line, it only contains header information
        data = parse_line(line)
        next if data[:supplier_product_code].blank? # The line is incomplete, skip it
        # check if we have the supply item
        local_supply_item = SupplyItem.where(:supplier_id => @supplier.id,
                                             :supplier_product_code => data[:supplier_product_code]).first
        # We do not have that supply item yet
        if local_supply_item.nil?
          si = new_supply_item(data)
          if si.save
            supplier_logger.info("[#{DateTime.now.to_s}] SupplyItem create: #{si.inspect}")
          else
            supplier_logger.error("Failed adding supply item during sync: #{si.inspect.to_s}, #{si.errors.to_s}")
          end
        # We already have that supply item and need to update that and related product information
        else
          update_supply_item(local_supply_item, data)
        end
      end
    end
  end

  def new_supply_item(data)
    si = @supplier.supply_items.new
    si.supplier_product_code = data[:supplier_product_code]
    si.name = "#{data[:name01]}"
    si.name += " #{data[:name02]}" unless data[:name02].blank?
    si.name += " (#{data[:name03]})" unless data[:name03].blank?
    si.name = si.name.strip
    si.name = si.name.gsub("ß","ss")
    si.manufacturer = "#{data[:manufacturer]}"
    si.product_link = "#{data[:product_link]}"
    si.pdf_url= "#{data[:pdf_url]}"
    si.weight = data[:weight].gsub(",",".").to_f
    si.manufacturer_product_code = "#{data[:manufacturer_product_code]}"
    si.description = "#{data[:description01].to_s.gsub("ß","ss")}"
    si.description += "#{data[:description02].to_s.gsub("ß","ss")}" unless data[:description02].blank?
    si.description = si.description.strip
    si.purchase_price = BigDecimal.new(data[:price_excluding_vat].to_s.gsub(",","."))
    # TODO: Read actual tax percentage from import file and create class as needed
    si.tax_class = TaxClass.find_by_percentage(8.0) or TaxClass.first
    si.stock = data[:stock_level].gsub("'","").to_i
    si.image_url = "#{data[:image_url]}" unless data[:image_url].blank?
    si.category01 = "#{data[:category01]}"
    si.category02 = "#{data[:category02]}"
    si.category03 = "#{data[:category03]}"
    return si
  end

  # If you want to implement a live update method for your own supplier util, subclass this class and override
  # live_update to return an array of change hashes like ActiveRecord uses them.
  def live_update(object)
    return nil
  end

end
