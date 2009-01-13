require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

InventoriesProperty = Opensteam::Inventory::InventoriesProperty

describe InventoriesProperty do
  before(:each) do
    @valid_attributes = {
    }
  end

  it "should associate with property" do
    InventoriesProperty.reflect_on_association( :property ).should_not be_nil
  end
  
  it "should have a belongs_to association with property" do
    InventoriesProperty.reflect_on_association( :property ).macro.should equal(:belongs_to)
  end
  
  it "should associate with inventory" do
	InventoriesProperty.reflect_on_association( :inventory ).should_not be_nil
  end
  
  it "should have a belongs_to association with inventory" do
      InventoriesProperty.reflect_on_association( :inventory ).macro.should equal(:belongs_to)
  end

  it "should create a new instance given valid attributes" do
    InventoriesProperty.create!(@valid_attributes)
  end
end
