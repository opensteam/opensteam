require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class DummyProperty1 < Property
end

class DummyProperty2 < Property
end



describe Property do
  before(:each) do

  end

  it "should associate with inventories_properties" do
    Property.reflect_on_association(:inventories_properties).should_not be_nil
  end

  it "should have a :has_many association with inventories_properties" do	
	Property.reflect_on_association(:inventories_properties).macro.should equal(:has_many)
  end

  it "should associate with inventories" do
    Property.reflect_on_association(:inventories).should_not be_nil
  end

  it "should have a :has_many association with inventories" do	
	Property.reflect_on_association(:inventories).macro.should equal(:has_many)
  end
  
  
  
  describe "being created" do
  
    before(:each) do
	  @property = nil
	  
	  @creating_property = lambda do
	    @property = create_property
        violated "#{@property.errors.full_messages.to_sentence}" if @property.new_record?
	  end
	  
	  
	  
	
	end
	
	it "should change count" do
	  @creating_property.should change(Property, :count).by(1)
	end

	
	it "should be valid" do
	  @creating_property.call
	  @property.should be_valid
	end

	
	it "should have no inventories" do
	  @creating_property.call
	  @property.inventories.should be_empty
	end


	it "should have no inventories_properties" do
	  @creating_property.call
	  @property.inventories_properties.should be_empty
	end
	
	it "value should be unique in class, :scope => 'type' " do
    @prop1 = DummyProperty1.new( :value => "value" )
    @prop1.should be_valid
    @prop1.save.should be_true
    
    @prop2 = DummyProperty1.new( :value => "value" )
    @prop2.should_not be_valid
    @prop2.errors.should_not be_empty
    
    
    @prop3 = DummyProperty2.new( :value => "value" )
    @prop3.should be_valid
    
  end
  

  end
  
  
  describe "property-inventory association" do
    before(:each) do
	  @property = create_property
	end
	
	it "should associate with inventories" do
	  @inventory1 = create_inventory
	  
	  @property.inventories.should be_empty
	  @property.inventories << @inventory1
	  @property.reload
	  @property.inventories.size.should be(1)

	  @inventory1.properties.size.should be(1)
	  @inventory1.properties.should == [ @property ]

	end
	
	it "should associate with multiple inventories" do
	  @inventory1 = create_inventory
	  @inventory2 = create_inventory
	  
	  @property.inventories.should be_empty
	  @property.inventories << @inventory1
	  @property.reload
	  @property.inventories.size.should be(1)
	  @property.inventories << @inventory2
	  @property.reload
	  @property.inventories.size.should be(2)
	  
	  
	  @inventory1.properties.size.should be(1)
	  @inventory1.properties.should == [ @property ]
	  
	  @inventory2.properties.size.should be(1)
	  @inventory2.properties.should == [ @property ]
	  
	end
	
	it "should build inventories" do
	  @property.inventories.should be_empty
	  @property.inventories.build( inventory_valid_attributes )
	  @property.should be_valid
	  @property.save
	  @property.reload
	  @property.inventories.should_not be_empty
	  @property.inventories.size.should be(1)
	end
	
	
	
	
  
  
  end
  
  

  
  protected
  
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
  
    def create_inventory( options = {} )
    record = Inventory.new( inventory_valid_attributes.merge( options ) )
	record.save
	record
  end
  
  
  def inventory_valid_attributes
	{
      :price => "9.99",
      :storage => "1",
      :active => false,
      :back_ordered => false,
      :comment => "value for comment"
    }
  end
  
  
end
