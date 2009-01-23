require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include OpensteamSpecHelper

InventoriesProperty = Opensteam::Inventory::InventoriesProperty

describe InventoriesProperty do
  before(:each) do
    @valid_attributes = {
    }
  end
  
  describe "property association" do
    it "should be valid" do
      test_association( InventoriesProperty.reflect_on_association( :property ), :macro => :belongs_to  )
    end
  end
  
  describe "inventory association" do
    it "should be valid" do
      test_association( InventoriesProperty.reflect_on_association( :inventory ), :macro => :belongs_to )
    end
  end

  it "should create a new instance given valid attributes" do
    InventoriesProperty.create!(@valid_attributes)
  end
end
