require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

def find_or_create_admin
  u = User.find_or_create_by_login( :login => 'admin',
    :email => 'admin@host.com',
    :password => 'opensteam',
    :password_confirmation => 'opensteam',
    :firstname => 'admin',
    :lastname => 'admin' )
  u.register!
  u.activate!

  p = UserRole.find_or_create_by_name( 'admin' )
  u.user_roles << p
  u.save
  u
end

describe Admin::Catalog::ProductsController do
  before(:each) do
    find_or_create_admin
    @user = User.authenticate( "admin", "opensteam" )
    @user.stub!(:is_admin?).and_return(true)
    request.session[:user_id] = @user.id
    @products = Product.all
  end
  
  it "should set routing" do
    route_for( :action => "index", :controller => "admin/catalog/products").should == '/admin/catalog/products'
    params_from( :get, '/admin/catalog/products').should == { :action => "index", :controller => 'admin/catalog/products' }
  end
  
  it "should get index" do
    get :index
    response.should be_success
    assigns[:products].should == @products
  end
end


describe Admin::Catalog::PropertiesController do
  before(:each) do
    find_or_create_admin
    @user = User.authenticate( "admin", "opensteam" )
    @user.stub!(:is_admin?).and_return(true)
    request.session[:user_id] = @user.id
    @properties = Property.all
  end
  
  it "should set routing" do
    route_for( :action => "index", :controller => "admin/catalog/properties").should == '/admin/catalog/properties'
    params_from( :get, '/admin/catalog/properties').should == { :action => "index", :controller => 'admin/catalog/properties' }
  end
  
  it "should get index" do
    get :index
    response.should be_success
    assigns[:properties].should == @properties
  end
end

describe Admin::Sales::InvoicesController do
  before(:each) do
    find_or_create_admin
    @user = User.authenticate( "admin", "opensteam" )
    @user.stub!(:is_admin?).and_return(true)
    request.session[:user_id] = @user.id
    @invoices = Opensteam::Models::Invoice.paginate( :page => 1, :per_page => 5, :order => "id asc" )
  end
  
  it "should set routing" do
    route_for( :action => "index", :controller => "admin/sales/invoices").should == '/admin/sales/invoices'
    params_from( :get, '/admin/sales/invoices').should == { :action => "index", :controller => 'admin/sales/invoices' }
  end
  
  it "should get index" do
    get :index
    response.should be_success
    assigns[:invoices].class.should be(WillPaginate::Collection)
    assigns[:invoices].should == @invoices
    assigns[:total_entries].should_not be_nil
  end
  
  it "should get index.xml" do
    get :index, :format => "xml"
    response.should be_success
  end
  
  it "should get show" do
    Opensteam::Models::Invoice.stub!(:find).and_return( @invoice = mock_model( Opensteam::Models::Invoice ) )
    @invoice.stub!(:order).and_return( @order = mock_model( Opensteam::Models::Order) )
    Opensteam::Models::Invoice.should_receive(:find).and_return( @invoice )
    @invoice.should_receive( :order ).and_return( @order )
  
    get :show, :id => 1
    response.should be_success
    
    assigns[:invoice].should be( @invoice )
    assigns[:order].should be(@order)
    
  end
  
  
  
end

describe Admin::Sales::ShipmentsController do
  before(:each) do
    find_or_create_admin
    @user = User.authenticate( "admin", "opensteam" )
    @user.stub!(:is_admin?).and_return(true)
    request.session[:user_id] = @user.id
    @shipments = Opensteam::Models::Shipment.paginate( :page => 1, :per_page => 5, :order => "id asc" )
        
  end
  
  it "should set routing" do
    route_for( :action => "index", :controller => "admin/sales/shipments").should == '/admin/sales/shipments'
    params_from( :get, '/admin/sales/shipments').should == { :action => "index", :controller => 'admin/sales/shipments' }
  end
  
  it "should get index" do
    get :index
    response.should be_success
    assigns[:shipments].class.should be(WillPaginate::Collection)
    assigns[:shipments].should == @shipments
    assigns[:total_entries].should_not be_nil
  end
  
  it "should get show" do
    Opensteam::Models::Shipment.stub!(:find).and_return( @shipment = mock_model( Opensteam::Models::Shipment ) )
    @shipment.stub!(:order).and_return( @order = mock_model( Opensteam::Models::Order) )
    Opensteam::Models::Shipment.should_receive(:find).and_return( @shipment )
    @shipment.should_receive( :order ).and_return( @order )
  
    get :show, :id => 1
    response.should be_success
    
    assigns[:shipment].should be( @shipment )
    assigns[:order].should be(@order)
    
  end
  
  it "should get index.xml" do
    get :index, :format => "xml"
    response.should be_success
  end
  
end

describe Admin::Config::TaxGroupsController do
  before(:each) do
    find_or_create_admin
    @user = User.authenticate( "admin", "opensteam" )
    @user.stub!(:is_admin?).and_return(true)
    request.session[:user_id] = @user.id
        
  end
  
  it "should set routing" do
    route_for( :action => "index", :controller => "admin/config/tax_groups").should == '/admin/config/tax_groups'
    params_from( :get, '/admin/config/tax_groups' ).should == { :action => "index", :controller => 'admin/config/tax_groups' }
  end
  
  it "should get index" do
    @tax_groups = ProductTaxGroup.paginate( :all, :page => params[:page], :per_page => params[:per_page] )
    #ProductTaxGroup.should_receive( :find ).and_return( @tax_groups )
    get :index
    response.should be_success
    assigns[:tax_groups].should == @tax_groups
  end

end
describe Admin::Config::ShippingRateGroupsController do
  before(:each) do
    find_or_create_admin
    @user = User.authenticate( "admin", "opensteam" )
    @user.stub!(:is_admin?).and_return(true)
    request.session[:user_id] = @user.id
        
  end
  
  it "should set routing" do
    route_for( :action => "index", :controller => "admin/config/shipping_rate_groups").should == '/admin/config/shipping_rate_groups'
    params_from( :get, '/admin/config/shipping_rate_groups').should == { :action => "index", :controller => 'admin/config/shipping_rate_groups' }
  end
  
  it "should get index" do
    @srgs = ShippingRateGroup.find( :all, :include => [ :shipping_rates, :payment_additions ] )
    ShippingRateGroup.should_receive( :find ).and_return(@srgs )
    get :index
    response.should be_success
    assigns[:groups].should == @srgs
  end
  
  it "should get edit" do
    ShippingRateGroup.stub!(:find).and_return( @g = mock_model( ShippingRateGroup ) )
    ShippingRateGroup.should_receive(:find).and_return( @g )
  
    get :edit, :id => 1
    response.should be_success
    assigns[:group].should be( @g )
  end
  
end
