module ProductCategory
  def self.included(base)
    base.class_eval do
      has_many :categories_products
      has_many :categories, :through => :categories_products
    end
  end
  
  def categories_ids
    self.categories.collect(&:id).join(",")
  end
  
  def categories_ids= i
    self.categories.collect(&:destroy)
    i.split(",").each do |category_id|
      Category.find( category_id ).products << self
    end
  end
  
  
end
