require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include OpensteamSpecHelper

class ProductsProperty < ActiveRecord::Base
end

class DummyProperty1 < Property
end

class DummyProperty2 < Property
end



describe Product do

  before(:each) do
  end


  
  it "should associate with properties_through_inventories" do
    Product.reflect_on_association(:properties_through_inventories).should_not be_nil
  end

  it "should have a :has_many association with properties_through_inventories" do	
	Product.reflect_on_association(:properties_through_inventories).macro.should equal(:has_many)
  end
  
  it "should associate with properties" do
    Product.reflect_on_association(:properties).should_not be_nil
  end

  it "should have a :has_many association with properties" do
    Product.reflect_on_association(:properties).macro.should equal(:has_many)
  end  

  
  describe "being created" do
  
    before(:each) do
	  @product = nil
	  
	  @creating_product = lambda do
	    @product = create_product
        violated "#{@product.errors.full_messages.to_sentence}" if @product.new_record?
	  end
	
	end
	
	it "should change count" do
	  @creating_product.should change(Product, :count).by(1)
	end

	
	it "should be valid" do
	  @creating_product.call
	  @product.should be_valid
	end

	
	it "should have no inventories" do
	  @creating_product.call
	  @product.inventories.should be_empty
	end

  end
  
  describe "product-properties association" do
    before(:each) do
	  @product = create_product
	end

    it "should associate product with properties" do
	  @property1 = create_property
	  @product.properties.should be_empty
	  @product.properties << @property1
	  @product.reload
	  @product.properties.should_not be_empty
	  @product.properties.size.should be(1)
	  @product.properties.first.should == @property1
	end
	
	
	it "should associate product with properties and update products_properties table" do
		@property1 = create_property( :value => "foo" )
		@product   = create_product( :name => "bar" )
		
		associate_properties = lambda do
		  @product.properties << @property1
		  @product.save
		end

		associate_properties.should change(ProductsProperty, :count).by(1)
	end
  end
  
  
  describe "inventory association" do  
	it "should associate with inventories" do
		Product.reflect_on_association(:inventories).should_not be_nil
	end

	it "should have a :has_many association with inventories" do	
		Product.reflect_on_association(:inventories).macro.should equal(:has_many)
	end
  
  end
  
  
  describe "inventory creation based on property_groups" do
  end
  
  
  describe "inventory creation based on given properties" do
	
	before(:each) do
	  @property1 = create_property( :value => 1 )
	  @property2 = create_property( :value => 2 )
	  
	  @product = create_product
	end
	
	
	it "should create an inventory item based on given properties" do
	  @product.inventories.should be_empty
	  @product.properties.should be_empty
	  @product.properties_through_inventories.should be_empty
	  
	  @product.build_inventory_for_properties( [ @property1, @property2 ] )

	  @product.save
	  @product.reload

	  @product.inventories.should_not be_empty
	  @product.properties_through_inventories.should_not be_empty
	  
	  @inventory = @product.inventories.first
	  
	  Inventory.by_properties( [ @property1, @property2 ] ).should == [ @inventory ]
	  @inventory.product.should == @product
	end
	
	
	it "should delete old inventory item before building new one based on given properties" do
	  @product.inventories.should be_empty
	  @product.properties.should be_empty
	  @product.properties_through_inventories.should be_empty
	  
	  @product.build_inventory_for_properties( [ @property1, @property2 ] )

	  @product.save
	  @product.reload
	  
	  @inventory = @product.inventories.first
	  
	  lambda { 
	    @product.build_inventory_for_properties( [ @property1, @property2 ], :delete_all => true )
	  }.should change(Inventory, :count).by(-1)
	  
	  @product.save
	  @product.reload
	  
	  @product.inventories.size.should be(1)
	  @product.inventories.first.should_not == @inventory
	end
	
	
	it "should create one inventory item if no properties are given" do
	
	  @product.inventories.should be_empty
	  @product.properties.should be_empty
	  @product.properties_through_inventories.should be_empty
	  
	 lambda {
	    @product.build_inventory_for_properties( [] )
		@product.save
	 }.should change(Inventory, :count ).by(1)
	  
	  @product.reload

	  @product.inventories.should_not be_empty
	  @product.properties_through_inventories.should be_empty

	end
  
  end
  
  
  # @product.inventories()
  # @product.inventories( [ @property, ...] )
  describe "inventory fetching" do
  
	before(:each) do
	  @product = create_product
	  @property1 = create_property
	  @property2 = create_property( :value => "123" )
	  @product.build_inventory_for_properties( [ @property1 ] )
	  @inventory1 = @product.inventories.last
	  @product.build_inventory_for_properties( [ @property2 ] )
	  @inventory2 = @product.inventories.last
	  @product.save
	end
	
    it "should fetch inventories based on properties" do
		@product.inventories.size.should be(2)
		@product.inventories( [ @property1 ] ).should == [ @inventory1 ]
		@product.inventories( [ @property2 ] ).should == [ @inventory2 ]
	end
  
  end
  
  
  # Product.has_many :property_groups
  describe "property-group association" do
    
    before(:each) do
      @product = create_product
      @property1 = DummyProperty1.create( :value => "one" )
      @property2 = DummyProperty1.create( :value => "two" )
      @property3 = DummyProperty2.create( :value => "three" )
      
      @product.property_groups.should be_empty
      @product.properties.should be_empty
      
      
    end
    
    
    
  
    it "should have a property_groups association" do
	  Product.reflect_on_association(:property_groups).should_not be_nil
	end
	
	it "should have a has_many association with property_groups" do
	  Product.reflect_on_association(:property_groups).macro.should == :has_many
	end
	
	it "should associate with property_groups" do
	  @group1 = create_property_group
	  @group1.product.should be_nil
	  
	 lambda {
	    @product.property_groups << @group1
		@product.save
	  }.should change( @group1, :product_id ).from(nil).to( @product.id )
	  
	  @product.reload
	  @product.property_groups.should_not be_empty
      @product.property_groups.size.should be(1)

	end
	
	it "should build property-groups based on given properties" do
    @product.properties << [ @property1, @property2, @property3 ]
    @product.should be_valid
    @product.properties.should_not be_empty
    
    @product.property_groups.build_for_properties( :properties => @product.properties, :group => :type, :limit => 2 )
    @product.should be_valid
    @product.property_groups.should_not be_empty
    
    @product.property_groups.first.properties.should_not be_empty
    @product.property_groups.first.properties.include?( @property1 ).should be_true
    @product.property_groups.first.properties.include?( @property2 ).should be_true
    @product.property_groups.first.properties.include?( @property3 ).should_not be_true
  end
  
  
  
  it "should build property-group for given properties are use existing property-group, based on :group" do
    @product.properties << [ @property1, @property2, @property3 ]
    @product.should be_valid
    @product.properties.should_not be_empty
    @product.property_groups.should be_empty
    
    @product.property_groups.build_for_properties( :properties => @product.properties, :group => :type, :limit => 2 )
    @product.should be_valid
    @product.property_groups.should_not be_empty
    
    @product.property_groups.first.properties.should_not be_empty
    @product.property_groups.first.properties.include?( @property1 ).should be_true
    @product.property_groups.first.properties.include?( @property2 ).should be_true
    @product.property_groups.first.properties.include?( @property3 ).should_not be_true
    
    @product.save.should be_true
    @product.reload
    
    @property4 = DummyProperty1.create( :value => "four" )
    
    @product.properties << @property4
    
    @group = @product.property_groups.first
    @product.property_groups.build_for_properties( :properties => @product.properties, :group => :type, :limit => 2 )
    @product.should be_valid
    @product.property_groups.should_not be_empty
    @product.property_groups.size.should be(1)
    @product.property_groups.first.should == @group
  end
  
  it "should use existing property-group and update properties" do
    @product.properties << [ @property1, @property2, @property3 ]
    @product.should be_valid
    @product.properties.should_not be_empty
    @product.property_groups.should be_empty
    
    @product.property_groups.build_for_properties( :properties => @product.properties, :group => :type, :limit => 2 )
    @product.should be_valid
    @product.property_groups.should_not be_empty
    
    @product.property_groups.first.properties.should_not be_empty
    @product.property_groups.first.properties.include?( @property1 ).should be_true
    @product.property_groups.first.properties.include?( @property2 ).should be_true
    @product.property_groups.first.properties.include?( @property3 ).should_not be_true
    
    @product.save.should be_true
    @product.reload
    
    @property4 = DummyProperty1.create( :value => "four" )
    
    @product.properties << @property4
    @product.properties.find( @property1 ).delete
    @product.save
    @product.reload
    
    @group = @product.property_groups.first
    @product.property_groups.build_for_properties( :properties => @product.properties, :group => :type, :limit => 2 )
    @product.should be_valid
    @product.property_groups.should_not be_empty
    @product.property_groups.size.should be(1)
    @product.property_groups.first.should == @group
    @product.property_groups.first.properties.include?( @property2 ).should be_true
    @product.property_groups.first.properties.include?( @property4 ).should be_true
    @product.property_groups.first.properties.include?( @property1 ).should_not be_true
    
    
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
