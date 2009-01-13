module OpensteamSpecHelper


  def create_property( options = {} )
    record = Property.new( property_valid_attributes.merge( options ) )
	record.save
	record
  end
  
  
  def property_valid_attributes
    @valid_attributes = {
      :type => "value for type",
      :value => "value for value",
      :unit => "value for unit"
    }
  end
  
  def create_property_group( options = {} )
    record = PropertyGroup.new( property_group_valid_attributes.merge( options ) )
	record.save
	record
  end
  
  def property_group_valid_attributes
	{
	  :name => "value for name",
      :description => "value for description",
      :selector => "select",
      :selector_text => "value for selector_text"
    }
  end
  
  def create_product( options = {} )
    record = Product.new( product_valid_attributes.merge( options ) )
	record.save
	record
  end
  
  
  def product_valid_attributes
    @valid_attributes = {
      :name => "value for name",
      :description => "value for description"
    }
  end


end
