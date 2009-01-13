require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class PropertiesPropertyGroup < ActiveRecord::Base
end

include OpensteamSpecHelper

describe PropertyGroup do

  describe "product property-group association" do
    it "should associate with a product" do
      PropertyGroup.reflect_on_association(:product).should_not be_nil
    end

    it "should have a :belongs_to association with product" do
      PropertyGroup.reflect_on_association(:product).macro.should == :belongs_to
    end
  end


  describe "properties property-group association" do
    it "should have a properties association" do
      PropertyGroup.reflect_on_association(:properties).should_not be_nil
    end

    it "should have a :has_and_belongs_to_many association with properties" do
      PropertyGroup.reflect_on_association(:properties).macro.should == :has_and_belongs_to_many
    end

    
    it "should raise an error, if added properties are not associated with the product and not add properties to group/product" do
      @product = create_product
      @product.property_groups.build( property_group_valid_attributes )
      @product.should be_valid
      @product.save
      @product.reload
      
      @product.properties.should be_empty
      
      @group = @product.property_groups.first
      @group.properties.should be_empty
      
      lambda { @group.properties << create_property }.should raise_error( ArgumentError )
      
      @group.properties.should be_empty
      @product.properties.should be_empty
            
      @group.reload
      @product.reload
      @group.properties.should be_empty
      @product.properties.should be_empty
    end
    
    
    it "should add properties to group, if properties are present in product, and not raise an error" do
      @product = create_product
      @product.property_groups.build( property_group_valid_attributes )
      @product.should be_valid
      @product.save
      @product.reload
      
      @product.properties.should be_empty
      @property = create_property
      @product.properties << @property
      @product.reload
      @product.properties.should_not be_empty

      @group = @product.property_groups.first
      @group.properties.should be_empty

      lambda { @group.properties << @property }.should_not raise_error( ArgumentError )
        
      @group.properties.should_not be_empty
      @product.properties.should_not be_empty

      @group.reload
      @product.reload
      @group.properties.should_not be_empty
      @product.properties.should_not be_empty
      ( @group.properties - @product.properties ).should be_empty
    
    end
    
    
    
    
    

  end


  describe "being created" do
    it "should change count when created" do
      lambda {
        create_property_group( :product => mock_model( Product ) )
        }.should change(PropertyGroup, :count).by(1)
      end

      it "should be valid" do
        create_property_group( :product => mock_model( Product ) ).should be_valid
      end

      it "should not be valid" do
        create_property_group( :selector => "foo" ).should_not be_valid
      end

    end


  end
