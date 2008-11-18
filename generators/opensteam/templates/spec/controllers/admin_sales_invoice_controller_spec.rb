require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Admin::Sales::InvoicesController do


  it "should user Admin::Sales::OrdersController" do
    controller.should be_an_instance_of( Admin::Sales::InvoicesController )
  end

  describe "routing" do
    it "should route 'index' action correctly" do
      route_for( :action => :index, :controller => "admin/sales/invoices" ).should == '/admin/sales/invoices'
    end

    it "should generate 'index' route correctly" do
      params_from(:get, '/admin/sales/invoices').should == { :action => 'index', :controller => 'admin/sales/invoices' }
    end
  end

  describe "GET 'index'" do



    before(:each) do
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

      @filter_entries = mock_model( FilterEntry )
      @user = User.authenticate( "admin", "opensteam")
      @user.stub!(:is_admin?).and_return(true)
      request.session[:user_id] = @user.id
    end

    it "should get index and assign invoices" do
      get :index

      response.should be_success
      assigns[:invoices].class.should == WillPaginate::Collection
    end




  end
end

  
__END__


@filter_entries = FilterEntry.find( profile_session.active_filter( self ) )
@orders = Order.filter( @filter_entries )


if params[:user_id]
  @customer = Opensteam::UserBase::User.find( params[:user_id] )
  @orders = ( @orders || Opensteam::OrderBase::Order ).by_user( params[:user_id ] )
end

@orders = ( @orders || Opensteam::OrderBase::Order ).paginate( :page => params[:page],
  :per_page => params[:per_page] || 20,
  :include => [ :customer, :shipping_address, :payment_address ],
  :order => "containers.id" )


respond_to do |format|
  format.html
  format.xml { render :xml => @orders.to_xml( :root => "orders" ) }
  format.js { render :update do |page|
      page.replace_html :grid, :partial => "orders", :object => @orders
      page.replace_html :filter, :partial => "admin/filters/filter", :locals => { :records => @orders, :model => "Order" }
    end
  }
end

end

describe "GET 'index'" do
it "should be successful" do
  get 'index'
  response.should be_success
end
end

describe "GET 'show'" do
it "should be successful" do
  get 'show'
  response.should be_success
end
end

describe "GET 'edit'" do
it "should be successful" do
  get 'edit'
  response.should be_success
end
end

describe "GET 'create'" do
it "should be successful" do
  get 'create'
  response.should be_success
end
end

describe "GET 'update'" do
it "should be successful" do
  get 'update'
  response.should be_success
end
end

describe "GET 'destroy'" do
it "should be successful" do
  get 'destroy'
  response.should be_success
end
end
end
