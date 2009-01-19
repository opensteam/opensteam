class Search < ActiveRecord::Base
  belongs_to :customer, :class_name => 'Opensteam::UserBase::Customer'
  
  serialize :properties
  
  def products
    find_products
  end
  
  private
  
  def find_products
    scope = Product.scoped({})
    
    # product klass
    scope = scope.scoped :conditions => { :type => self.klass } unless self.klass.blank?

    ## inventory price and storage
    scope = scope.scoped :conditions => ['inventories.price >= ?', minimum_price ] unless minimum_price.blank?
    scope = scope.scoped :conditions => ['inventories.price <= ?', maximum_price ] unless maximum_price.blank?
    scope = scope.scoped :conditions => ['inventories.price >= ?', minimum_storage ] unless minimum_storage.blank?
    scope = scope.scoped :conditions => ['inventories.storage <= ?', maximum_storage ] unless maximum_storage.blank?

    # properties
    self.properties.each do |props|
      scope = scope.scoped :joins => :properties, :conditions => { :properties => { :type => props[:klass], :value => props[:value] } } unless props[:value].blank?
    end if self.properties
    
    
    # keyword
    scope = scope.scoped :include => :properties, :conditions => [ keyword_columns.collect { |s| "#{s} LIKE :keyword" }.join(" OR " ), { :keyword => "%#{keywords}%" } ] unless keywords.blank?
    scope
  end
  
  
  def keyword_columns
    [ "products.type", "products.name", "properties.type", "properties.value", "products.description" ]
  end
  

  def find_products_for(klass)
    scope = klass.scoped({})
    scope = scope.scoped :include => { :inventories_properties => :property }, :conditions => ["#{klass.table_name}.name LIKE ? OR #{klass.table_name}.description LIKE ? OR properties.name LIKE ?",
      "%#{keywords}%", "%#{keywords}%", "%#{keywords}%"] unless keywords.blank?
    scope = scope.scoped :include => :inventories, :conditions => ['inventories.price >= ?', minimum_price ] unless minimum_price.blank?
    scope = scope.scoped :include => :inventories, :conditions => ['inventories.price <= ?', maximum_price ] unless maximum_price.blank?
    scope = scope.scoped :include => :inventories, :conditions => ['inventories.price >= ?', minimum_storage ] unless minimum_storage.blank?
    scope = scope.scoped :include => :inventories, :conditions => ['inventories.storage <= ?', maximum_storage ] unless maximum_storage.blank?
    scope
  end


  class Property
    attr_accessor :klass, :value
  end
  
  
  
  
  
  
end
