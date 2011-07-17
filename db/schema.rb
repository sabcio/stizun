# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110716074208) do

  create_table "addresses", :force => true do |t|
    t.string   "company"
    t.string   "firstname"
    t.string   "lastname"
    t.string   "street"
    t.string   "postalcode"
    t.string   "city"
    t.string   "email"
    t.integer  "country_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",     :default => "active"
  end

  add_index "addresses", ["user_id"], :name => "index_addresses_on_user_id"

  create_table "admin_addresses", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "admin_orders", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "attachments", :force => true do |t|
    t.integer "product_id"
    t.string  "file"
  end

  create_table "carts", :force => true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "carts", ["user_id"], :name => "index_carts_on_user_id"

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "supplier_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "ancestry"
  end

  add_index "categories", ["ancestry"], :name => "index_categories_on_ancestry"
  add_index "categories", ["parent_id"], :name => "index_categories_on_parent_id"

  create_table "categories_products", :id => false, :force => true do |t|
    t.integer "category_id"
    t.integer "product_id"
  end

  add_index "categories_products", ["category_id", "product_id"], :name => "cp_cid_pid"
  add_index "categories_products", ["category_id"], :name => "index_categories_products_on_category_id"
  add_index "categories_products", ["product_id", "category_id"], :name => "cp_pid_cid"
  add_index "categories_products", ["product_id"], :name => "index_categories_products_on_product_id"

  create_table "ckeditor_assets", :force => true do |t|
    t.string   "data_file_name",                                 :null => false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "assetable_id"
    t.string   "assetable_type",    :limit => 30
    t.string   "type",              :limit => 25
    t.string   "guid",              :limit => 10
    t.integer  "locale",            :limit => 1,  :default => 0
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ckeditor_assets", ["assetable_type", "assetable_id"], :name => "fk_assetable"
  add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], :name => "idx_assetable_type"
  add_index "ckeditor_assets", ["user_id"], :name => "fk_user"

  create_table "configuration_items", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "key"
    t.string   "value"
    t.string   "name"
    t.string   "description"
  end

  add_index "configuration_items", ["key"], :name => "index_configuration_items_on_key"

  create_table "countries", :force => true do |t|
    t.string   "name"
    t.string   "sortorder"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "document_lines", :force => true do |t|
    t.integer  "quantity"
    t.decimal  "price",        :precision => 10, :scale => 0
    t.integer  "product_id"
    t.string   "note"
    t.string   "type"
    t.integer  "cart_id"
    t.integer  "invoice_id"
    t.integer  "old_order_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "document_lines", ["cart_id"], :name => "index_document_lines_on_cart_id"
  add_index "document_lines", ["invoice_id"], :name => "index_document_lines_on_invoice_id"
  add_index "document_lines", ["old_order_id"], :name => "index_document_lines_on_order_id"
  add_index "document_lines", ["product_id"], :name => "index_document_lines_on_product_id"

  create_table "feed_entries", :force => true do |t|
    t.string   "title"
    t.text     "content"
    t.string   "url"
    t.string   "guid"
    t.datetime "published_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "histories", :force => true do |t|
    t.text     "text"
    t.string   "object_type"
    t.integer  "object_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "type_const"
  end

  create_table "invoices", :force => true do |t|
    t.integer  "shipping_address_id"
    t.string   "shipping_address_type"
    t.integer  "billing_address_id"
    t.string   "billing_address_type"
    t.integer  "user_id"
    t.integer  "status_constant",                                       :default => 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "uuid"
    t.decimal  "shipping_cost",         :precision => 63, :scale => 30
    t.integer  "old_order_id"
    t.integer  "payment_method_id"
    t.integer  "document_number"
    t.boolean  "autobook",                                              :default => true
    t.decimal  "shipping_taxes",        :precision => 63, :scale => 30
    t.integer  "order_id"
    t.decimal  "rebate",                :precision => 63, :scale => 30, :default => 0.0
    t.integer  "replacement_id"
  end

  add_index "invoices", ["old_order_id"], :name => "index_invoices_on_order_id"
  add_index "invoices", ["user_id"], :name => "index_invoices_on_user_id"
  add_index "invoices", ["uuid"], :name => "index_invoices_on_uuid"

  create_table "notifications", :force => true do |t|
    t.string   "email"
    t.string   "remove_hash"
    t.integer  "product_id"
    t.integer  "user_id"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "numerators", :force => true do |t|
    t.integer  "count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "old_orders", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "shipping_address_id"
    t.integer  "billing_address_id"
    t.string   "shipping_address_type"
    t.string   "billing_address_type"
    t.integer  "status_constant",       :default => 1
    t.integer  "payment_method_id"
    t.integer  "document_number"
    t.integer  "shipping_carrier_id"
    t.string   "tracking_number"
  end

  add_index "old_orders", ["user_id"], :name => "index_orders_on_user_id"

  create_table "orders", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "shipping_address_id"
    t.string   "shipping_address_type"
    t.integer  "billing_address_id"
    t.string   "billing_address_type"
    t.integer  "user_id"
    t.integer  "status_constant",                                       :default => 1
    t.string   "uuid"
    t.decimal  "shipping_cost",         :precision => 63, :scale => 30
    t.integer  "payment_method_id"
    t.integer  "document_number"
    t.decimal  "shipping_taxes",        :precision => 63, :scale => 30
    t.integer  "shipping_carrier_id"
    t.string   "tracking_number"
    t.boolean  "direct_shipping",                                       :default => false
    t.decimal  "rebate",                :precision => 63, :scale => 30, :default => 0.0
  end

  create_table "pages", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payment_methods", :force => true do |t|
    t.string   "name"
    t.boolean  "allows_direct_shipping"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "default"
  end

  create_table "payment_methods_users", :id => false, :force => true do |t|
    t.integer "payment_method_id"
    t.integer "user_id"
  end

  add_index "payment_methods_users", ["payment_method_id", "user_id"], :name => "pmu_pmid_uid"
  add_index "payment_methods_users", ["payment_method_id"], :name => "index_payment_methods_users_on_payment_method_id"
  add_index "payment_methods_users", ["user_id", "payment_method_id"], :name => "pmu_uid_pmid"
  add_index "payment_methods_users", ["user_id"], :name => "index_payment_methods_users_on_user_id"

  create_table "product_pictures", :force => true do |t|
    t.integer  "product_id"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.boolean  "is_main_picture"
  end

  create_table "product_sets", :force => true do |t|
    t.integer "quantity"
    t.integer "product_id"
    t.integer "component_id"
  end

  create_table "products", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "tax_class_id"
    t.decimal  "purchase_price",            :precision => 20, :scale => 2,  :default => 0.0
    t.decimal  "margin_percentage",         :precision => 8,  :scale => 2,  :default => 0.0
    t.decimal  "sales_price",               :precision => 20, :scale => 2,  :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "supplier_id"
    t.float    "weight"
    t.boolean  "direct_shipping",                                           :default => true
    t.string   "supplier_product_code"
    t.integer  "stock",                                                     :default => 0
    t.boolean  "is_available",                                              :default => true
    t.integer  "supply_item_id"
    t.string   "manufacturer_product_code"
    t.decimal  "absolute_rebate",           :precision => 63, :scale => 30, :default => 0.0
    t.decimal  "percentage_rebate",         :precision => 63, :scale => 30, :default => 0.0
    t.datetime "rebate_until"
    t.boolean  "is_loss_leader"
    t.boolean  "delta",                                                     :default => true,  :null => false
    t.text     "short_description"
    t.boolean  "sale_state",                                                :default => false
    t.string   "manufacturer"
    t.string   "product_link"
    t.decimal  "cached_price",              :precision => 63, :scale => 30
    t.decimal  "cached_taxed_price",        :precision => 63, :scale => 30
    t.datetime "auto_updated_at"
  end

  add_index "products", ["supplier_id"], :name => "index_products_on_supplier_id"
  add_index "products", ["supply_item_id"], :name => "index_products_on_supply_item_id"

  create_table "shipping_carriers", :force => true do |t|
    t.string "name"
    t.string "tracking_base_url"
  end

  create_table "shipping_costs", :force => true do |t|
    t.integer  "shipping_rate_id"
    t.integer  "weight_min"
    t.integer  "weight_max"
    t.decimal  "price",            :precision => 63, :scale => 30
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tax_class_id"
  end

  add_index "shipping_costs", ["shipping_rate_id"], :name => "index_shipping_costs_on_shipping_rate_id"

  create_table "shipping_rates", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tax_class_id"
    t.decimal  "direct_shipping_fees", :precision => 63, :scale => 30, :default => 0.0
    t.boolean  "default",                                              :default => false
  end

  create_table "static_document_lines", :force => true do |t|
    t.integer  "quantity"
    t.string   "text"
    t.decimal  "single_rounded_price",      :precision => 63, :scale => 30
    t.decimal  "taxes",                     :precision => 63, :scale => 30
    t.decimal  "tax_percentage",            :precision => 8,  :scale => 2
    t.integer  "invoice_id"
    t.float    "weight"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "gross_price",               :precision => 63, :scale => 30
    t.decimal  "taxed_price",               :precision => 63, :scale => 30
    t.decimal  "single_price",              :precision => 63, :scale => 30
    t.integer  "order_id"
    t.string   "manufacturer"
    t.string   "manufacturer_product_code"
    t.integer  "product_id"
    t.decimal  "single_untaxed_price",      :precision => 63, :scale => 30
    t.decimal  "single_rebate",             :precision => 63, :scale => 30, :default => 0.0
  end

  add_index "static_document_lines", ["invoice_id"], :name => "index_invoice_lines_on_invoice_id"

  create_table "suppliers", :force => true do |t|
    t.string   "name"
    t.integer  "address_id"
    t.integer  "shipping_rate_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "product_base_url"
    t.string   "utility_class_name"
  end

  add_index "suppliers", ["shipping_rate_id"], :name => "index_suppliers_on_shipping_rate_id"

  create_table "supply_items", :force => true do |t|
    t.string   "supplier_product_code"
    t.string   "name"
    t.float    "weight"
    t.integer  "supplier_id"
    t.string   "description"
    t.decimal  "purchase_price",            :precision => 20, :scale => 2, :default => 0.0
    t.integer  "stock"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "manufacturer_product_code"
    t.boolean  "delta",                                                    :default => true, :null => false
    t.string   "manufacturer"
    t.string   "product_link"
    t.integer  "status_constant"
    t.text     "image_url"
    t.text     "pdf_url"
    t.string   "category01"
    t.string   "category02"
    t.string   "category03"
    t.integer  "category_id"
    t.integer  "workflow_status_constant",                                 :default => 1
    t.string   "notes"
  end

  add_index "supply_items", ["supplier_id"], :name => "index_supply_items_on_supplier_id"

  create_table "tax_classes", :force => true do |t|
    t.string   "name"
    t.decimal  "percentage", :precision => 8, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "usergroups", :force => true do |t|
    t.string  "name"
    t.boolean "is_admin"
  end

  create_table "usergroups_users", :id => false, :force => true do |t|
    t.integer "usergroup_id"
    t.integer "user_id"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "encrypted_password"
    t.string   "password_salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.integer  "sign_in_count",        :default => 0, :null => false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "reset_password_token"
    t.datetime "remember_created_at"
    t.string   "authentication_token"
  end

end
