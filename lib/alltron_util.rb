# encoding: utf-8
require 'supplier_util'

class AlltronUtil < SupplierUtil

  def initialize
    # The CSV file header looks like this:
    # 0                 1               2           3               4               5           6                  7                     8           9         10          11                  12          13          14              15                  16                17            18             19            20          21          22              23                   24
    # Artikelnummer 2   Artikelnummer   Bezeichung  Bezeichung 2    Lagerbestand    Gewicht    Preis (inkl. MWSt)  Preis (exkl. MWSt)    WWW-Link    Webtext   Webtext 2   Herstellernummer    Hersteller  MWST Satz   Endkundenpreis  Garantie (Monate)   Erfassungsdatum   Kategorie 1   Kategorie 2    Kategorie 3   Kategorie   EAN-Code    Lieferdatum     Ausverkaufsartikel   Discountpreis
    @supplier = Supplier.where(:name => 'Alltron AG').first
    if @supplier.nil?
      @supplier = Supplier.new
      @supplier.name = "Alltron AG"
      sr = ShippingRate.get_default
      @supplier.shipping_rate = sr
      @supplier.save
    end
    @field_mapping = {:name01 => 2, # 'Bezeichung',
                      :name02 => 3, #'Bezeichung 2',
                      :name03 => nil,
                      :description01 => 8, #'Webtext',
                      :description02 => 9, #'Webtext 2',
                      :supplier_product_code => 0, #'Artikelnummer 2',
                      :price_excluding_vat => 7, #'Preis (exkl. MWSt)',
                      :stock_level => 4, #'Lagerbestand',
                      :manufacturer_product_code => 11, #'Herstellernummer',
                      :manufacturer => 12, #'Hersteller',
                      :weight => 5, #'Gewicht',
                      :pdf_url => nil,
                      :product_link => 8, #'WWW-Link',
                      :category01 => 17, #'Kategorie 1',
                      :category02 => 18, #'Kategorie 2',
                      :category03 => 19, #'Kategorie 3'}
                      }

    # Possible options:
    #   :col_sep => the separator character to split() on
    @csv_parse_options = { :col_sep => "\t" }
  end

  def self.data_directory
    return Rails.root + "lib"
  end

  def self.import_filename
    return @infile = self.data_directory + "AL_Artikeldaten.txt"
  end

  # Synchronize all supply items from a supplier's provided CSV file
  def import_supply_items(filename = self.import_filename)
    AlltronUtil.create_shipping_rate
    super
  end

  def quick_update_stock(filename)
    require 'nokogiri'
    stocked_supplier_product_codes = @supplier.supply_items.collect(&:supplier_product_code)
    @updates = []
    doc = Nokogiri::XML(open(filename))
#     binding.pry
    doc.xpath("//item").each do |ele|
      supplier_product_code = ele.children.xpath("../LITM").first.content
      stock = ele.children.xpath("../STQU").first.content
      # Only accept the update if it's something we're stocking
      @updates << [supplier_product_code, stock.to_i] unless (supplier_product_code.blank? or !stocked_supplier_product_codes.include?(supplier_product_code))
    end
    super
  end

  # Create a default shipping rate for this supplier if it doesn't exist.
  # This supplier may accidentally not have a matching shipping rate set up,
  # which would ruin shipping calculations. Create a rate with sane defaults
  # if that's the case.
  def self.create_shipping_rate

    # Post
    # Post Pac Priority   Preis in CHF (exkl. MwSt)
    # Grundtaxe   8.00
    # pro Kilo    + 0.65
    # Stückgut via Setz
    # Volumen   Preis in CHF (exkl. MwSt)
    # Colis 30 - 100 kg   58.60
    # 1 Palette   69.70
    # 2 Paletten    139.50
    # 3 Paletten    209.10
    # 4 Paletten    278.80
    # 5 Paletten    348.51
    # Sonderleistungen
    # Leistung    Preis in CHF (exkl. MwSt)
    # Direktlieferung an einen Endkunden    + 4.70
    # Express-Lieferung per Post    + 14.00
    # Nachnahme   + 14.00
    # Express-Lieferung durch Setz    nach Aufwand
    # Lieferung durch Kurierdienst    nach Aufwand

    supplier = Supplier.find_or_create_by_name("Alltron AG")
    if supplier.shipping_rate.nil?

      tc = TaxClass.find_or_create_by_percentage_and_name(:percentage => 8.0,
                                                          :name => 'Schweizer Mehrwertsteuer (Normalsatz)')
      shipping_rate = ShippingRate.new(:name => "Alltron AG")
      shipping_rate.tax_class = tc
      # min_weight, max_weight, price (without VAT)
      costs = [
                [0, 1000, 8.65],
                [1001, 2000, 9.3],
                [2001, 3000, 9.95],
                [3001, 4000, 10.6],
                [4001, 5000, 11.25],
                [5001, 6000, 11.9],
                [6001, 7000, 12.55],
                [7001, 8000, 13.2],
                [8001, 9000, 13.85],
                [9001, 10000, 14.5],
                [10001, 11000, 15.15],
                [11001, 12000, 15.8],
                [12001, 13000, 16.45],
                [13001, 14000, 17.1],
                [14001, 15000, 17.75],
                [15001, 16000, 18.4],
                [16001, 17000, 19.05],
                [17001, 18000, 19.7],
                [18001, 19000, 20.35],
                [19001, 20000, 21.0],
                [20001, 21000, 21.65],
                [21001, 22000, 22.3],
                [22001, 23000, 22.95],
                [23001, 24000, 23.6],
                [24001, 25000, 24.25],
                [25001, 26000, 24.9],
                [26001, 27000, 25.55],
                [27001, 28000, 26.2],
                [28001, 29000, 26.85],
                [29001, 30000, 27.5],
                [30001, 100000, 58.60]
              ]
      costs.each do |c|
        shipping_rate.shipping_costs << ShippingCost.new(:weight_min => c[0],
                                                         :weight_max => c[1],
                                                         :price => c[2],
                                                         :tax_class => tc)
      end
      shipping_rate.save
      supplier.shipping_rate = shipping_rate
      supplier.save
      return shipping_rate
    end
    return supplier.shipping_rate
  end

end
