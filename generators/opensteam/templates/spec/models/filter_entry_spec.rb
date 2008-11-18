require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Opensteam::System::FilterEntry do
  FilterEntry = Opensteam::System::FilterEntry
  before(:each) do
    @valid_attributes = {
      :key => "id",
      :val => 1,
      :op => ">"
    }
    @model = Order # Opensteam::OrderBase::Order
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

  it "should create valid conditions from valid attributes" do
    filter = FilterEntry.new( @valid_attributes )
    filter.conditions( @model ).class.should be(Array)
  end
  
  it "should get column name" do
    @model.configure_filter( {} )
    filter = FilterEntry.new( @valid_attributes )
    filter.model = @model
    filter.send( :parse_column, filter.key ).should eql( "#{@model.table_name}.id" )
  end
  
  it "should get configured column name" do
    @model.configure_filter( :id => "tests.id" )
    filter = FilterEntry.new( @valid_attributes )
    filter.model = @model
    filter.send( :parse_column, filter.key ).should eql( "tests.id" )
  end
  
  it "should get configured column names" do
    @model.configure_filter( :id => [ "tests.id", "tests.id2" ] )
    filter = FilterEntry.new( @valid_attributes )
    filter.model = @model
    filter.send( :parse_column, filter.key ).should eql [ "tests.id", "tests.id2" ]
  end
  
  it "should get associated column name" do
    filter = FilterEntry.new( @valid_attributes.merge( :key => "customer" ) )
    filter.model = @model
    filter.send( :parse_column, filter.key ).should eql( "users.customer" ) 
  end
  
  
  it "should return a scope" do
    filter = FilterEntry.new( @valid_attributes )
    filter.scope_for( @model ).class.should be( ActiveRecord::NamedScope::Scope )
  end

  it "should receive parse_column" do
    filter = FilterEntry.new( @valid_attributes.merge( { :key => "created_at", :op => ">", :val => 0 } ) )
    filter.should_receive( :parse_column ).once
    filter.conditions( @model )
  end

  it "should receive parse_column" do
    filter = FilterEntry.new( @valid_attributes.merge( { :key => "created_at", :op => ">", :val => 0 } ) )
    filter.should_receive( :check_operator ).with( filter.op ).once
    filter.conditions( @model )
  end

end
