class Search < ActiveRecord::Base
  belongs_to :customer, :class_name => 'Opensteam::UserBase::Customer'
  
  def products
    @products ||= find_products
  end
  
  
  private
  
  def find_products
    klasses = []
    ( klasses << ( kind.blank? ? Opensteam::Find.find_product_klasses : kind.classify.constantize ) ).flatten!
    klasses.inject([]) do |ret, klass|
      ret += find_products_for( klass )
    end
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

  
  
  
  
  
  
end
