require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include OpensteamSpecHelper

describe Inventory do
  fixtures :products, :properties
  
  before(:each) do

  end

  describe "inventories_properties association" do
    it "should be valid" do
      test_association( Inventory.reflect_on_association(:inventories_properties) )
    end
  end
  

  describe "properties association" do
    it "should be valid" do
      test_association( Inventory.reflect_on_association(:properties) )
    end
  end
  
  describe "being created" do
  
    before(:each) do
	  @inventory = nil
	  
	  @inventory_creating = lambda do
	    @inventory = create_inventory
        violated "#{@inventory.errors.full_messages.to_sentence}" if @inventory.new_record?
	  end
	
	end
	
	it "should change count" do
	  @inventory_creating.should change(Inventory, :count).by(1)
	end

	
	it "should be valid" do
	  @inventory_creating.call
	  @inventory.should be_valid
	end

	
	it "should have no properties" do
	  @inventory_creating.call
	  @inventory.properties.should be_empty
	end


	it "should have no inventories_properties" do
	  @inventory_creating.call
	  @inventory.inventories_properties.should be_empty
	end

  end
  
  
  describe "named_scope :by_properties" do
    before(:each) do
      Inventory.delete_all
	  @inventory_p12 = create_inventory
	  @p1 = create_property(:value => 1 )
	  @p2 = create_property(:value => 2 )
	  @inventory_p12.properties << [@p1, @p2]
	  
	  @inventory_p3 = create_inventory
	  @p3 = create_property( :value => 3 )
	  @inventory_p3.properties << @p3
	  
	  @inventory_empty = create_inventory
	end
	
	
	it "should find inventories based on given properties" do
		Inventory.by_properties( [@p1, @p2 ]).should == [ @inventory_p12 ]
		Inventory.by_properties( [@p2, @p1 ]).should == [ @inventory_p12 ]
	
		Inventory.by_properties( [@p3] ).should_not == [ @inventory_p12 ]
		Inventory.by_properties( [@p3] ).should == [ @inventory_p3 ]
	end



	it "should not find inventory based on given properties" do
		Inventory.by_properties( [ create_property ] ).should be_empty
		Inventory.by_properties( [] ).should be_empty
	end
  end
  
  
  
  
  describe "product-inventory association" do
    
	before(:each) do
	  @inventory = create_inventory
	end
	
	it "should associate with product" do
      Inventory.reflect_on_association(:product).should_not be_nil
    end

    it "should have a :belongs_to association with products" do	
	  Inventory.reflect_on_association(:product).macro.should equal(:belongs_to)
    end
  
	
	it "should associate with product object" do
	  @inventory.product.should be_nil
	  @shirt = products(:shirt_one)
	  
	  @inventory.product = @shirt
	  @inventory.save
	  @inventory.reload
	  @inventory.product.should == @shirt
	end
  end
  
  
  describe "properties-inventory association" do
    
	before(:each) do
	  @inventory = create_inventory
	end
	
	it "should associate with property objects" do
	  @inventory.properties.should be_empty
	  @red = properties(:color_red)
	  
	  @inventory.properties << @red
	  @inventory.save
	  @inventory.reload
	  @inventory.properties.size.should == 1
	  
	  @blue = properties(:color_blue)
	  
	  @inventory.properties << @blue
	  @inventory.save
	  @inventory.reload
	  @inventory.properties.size.should == 2
	end
  end
  
  
  
  
  
  protected
  
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
