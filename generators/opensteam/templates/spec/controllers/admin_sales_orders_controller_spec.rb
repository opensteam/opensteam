require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Admin::Sales::OrdersController do


  it "should user Admin::Sales::OrdersController" do
    controller.should be_an_instance_of( Admin::Sales::OrdersController )
  end

  describe "routing" do
    it "should route 'index' action correctly" do
      route_for( :action => :index, :controller => "admin/sales/orders" ).should == '/admin/sales/orders'
    end

    it "should generate 'index' route correctly" do
      params_from(:get, '/admin/sales/orders').should == { :action => 'index', :controller => 'admin/sales/orders' }
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
      @orders = Order.paginate( :page => 1, :per_page => 20, :order => 'containers.id')
      request.session[:user_id] = @user.id
    end

    it "should redirect to login" do
      request.session[:user_id] = nil
      get :index
      response.should redirect_to('/login')
    end


    it "should check filter for Orders" do
      FilterEntry.should_receive(:find).once.and_return( @filter_entries )
      Order.should_receive(:filter).once.with( @filter_entries ).and_return( Order )
      get :index
      response.should be_success
    end

    it "should get index and Order should receive filter" do
      Order.should_receive( :filter ).once.and_return( Order )
      get :index
      response.should be_success
    end

    it "should get index and Order should receive paginate" do
      Order.should_receive( :paginate ).once
      get :index
      response.should be_success
    end

    it "should get index with user_id and assign user" do
      User.should_receive(:find).once.with( @user.id.to_s ).and_return( @user )
      get :index, :user_id => @user.id
      response.should be_success
      assigns[:customer].should be(@user)
    end


    it "should get index and assign orders" do
      get :index
      assigns[:orders].class.should be(WillPaginate::Collection)
      assigns[:orders].should == @orders
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
