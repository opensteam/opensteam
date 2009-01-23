require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe "Taxes" do
  describe Opensteam::Sales::Money::Tax::ProductTaxGroup do
    ProductTaxGroup = Opensteam::Sales::Money::Tax::ProductTaxGroup

    describe "associations" do
      
      describe "inventories" do
        
        it "should associate" do
          ProductTaxGroup.reflect_on_association( :inventories ).should_not be_nil
        end
      
        it "should have a :has_many :association" do
          ProductTaxGroup.reflect_on_association( :inventories ).macro.should == :has_many
        end

        it "should have a valid class_name " do
          lambda { 
            ProductTaxGroup.reflect_on_association( :inventories ).class_name.constantize
          }.should_not raise_error
        end
        
      end
    
    
    end
    


  end
  
end
