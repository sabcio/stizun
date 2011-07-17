class Category < ActiveRecord::Base
  has_and_belongs_to_many :products
  belongs_to :supplier
  has_many :supply_items
  
  #acts_as_tree :order => "name"
  
#  acts_as_nested_set :order => "name"
  has_ancestry
  
  after_save :expire_cache_fragments
  after_destroy :expire_cache_fragments

  def fully_qualified_name
    trail = ""
    for cat in ancestors
      trail += cat.name 
      trail += " >> "
    end
    trail += name
    return trail
  end
  
  # Abstraction so we can switch out better_nested_set for something
  # else if it becomes necessary. Returns the category and all its
  # ancestors up to the root of the tree or graph.
  def ancestor_chain
    self_and_ancestors
  end
  
  # Returns all child, subchild, ... , categories with self
  def children_categories
    #self_and_descendants.collect(&:children_categories)
    ([self] + children.collect(&:children_categories)).flatten
  end
  
  # Returns all child, subchild supply items
  def children_supply_items
    ([self.supply_items] + children.collect(&:children_supply_items)).flatten
  end
  
  
  # It will only look for categories in one supplier's node
  def find_or_create_by_name(name, level = nil, supplier = nil, create = true)
    categories = children_categories.flatten
    tab = []
    categories.each { |category| tab << category if category.name.eql? name }
    found = tab.index {|category| category.level.eql? level }
    if found
      tab[found]
    elsif create 
      Category.create!(:name => name, :parent_id => self.id, :supplier_id => supplier.id) unless name.empty?
    end
  end
  
  # Finding correct category for a supplyitem
  def category_from_csv(category1, category2, category3)
    if !(category3.blank?)
      self.find_or_create_by_name(category3, 3, nil, false).id
    elsif !(category2.blank?)
      self.find_or_create_by_name(category2, 2, nil, false).id
    elsif !(category1.blank?)
      self.find_or_create_by_name(category1, 1, nil, false).id
    else
      self.reload
      self.find_or_create_by_name("Without category", 1, self.supplier, true).id
    end
  end

  # Whenever any category changes, we need to expire all category-related
  # caches
  def expire_cache_fragments
    Supplier.all.each do |sup|
      Rails.cache.delete("supplier_#{sup.id}_categories_sorted")
    end
  end

end
