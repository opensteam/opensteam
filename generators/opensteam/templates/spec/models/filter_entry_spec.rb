require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Opensteam::Helpers::Grid do
  FilterEntry = Opensteam::Helpers::Grid::FilterEntry
  before(:each) do
    @valid_attributes = {
      :key => "id",
      :val => 1,
      :op => ">"
    }
    @model = Order # Opensteam::Sales::OrderBase::Order
  end

  it "should create a new instance given valid attributes" do
    FilterEntry.create!( @valid_attributes )
  end
  
  it "should be valid" do
    filter = FilterEntry.new( @valid_attributes )
    filter.should be_valid
  end

  it "should not be valid due to unallowed operator" do
    filter = FilterEntry.new( @valid_attributes.merge( :op => "NOT VALID" ) )
    filter.should_not be_valid
  end

  
  it "model should get configured column name" do
    @model.configure_grid( :id => :buh )
    filter = FilterEntry.new( @valid_attributes )
    @model.grid_column( filter.key ).should eql( :buh )
  end
    

end
