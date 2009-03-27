class PropertyGroup < ActiveRecord::Base
  #has_many :properties_property_groups
  has_and_belongs_to_many :properties, #:through => :properties_property_groups, 
    :before_add => :check_product_property_integrity

  belongs_to :product, :class_name => "Opensteam::Models::Product"

  validates_presence_of :selector, :selector_text
  validates_inclusion_of :selector, :in => %w( radio_button select )
  validates_presence_of :product

  private
  def check_product_property_integrity(p)
    raise ArgumentError, "added Property #{p} is not a property of product #{self.product}" unless
      ( self.product.properties & Array(p) ) == Array(p)
  end


  
  
end
