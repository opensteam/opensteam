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

      Order.configure_grid(
        :id => :id,
        :order_items => :items_count,
        :customer => { :customer => :email },
        :shipping_address => { :shipping_address => [ :firstname, :lastname, :street, :postal, :city, :country ] },
        :payment_address => {  :payment_address => [ :firstname, :lastname, :street, :postal, :city, :country ] },
        :state => :state,
        :created_at => :created_at,
        :updated_at => :updated_at
      )
      

      @filter_entries = mock_model( FilterEntry )
      @user = User.authenticate( "admin", "opensteam")
      @user.stub!(:is_admin?).and_return(true)
      @orders = Order.paginate( :page => 1, :per_page => 20, :order => "id ASC" )
      request.session[:user_id] = @user.id
    end

    it "should redirect to login" do
      request.session[:user_id] = nil
      get :index
      response.should redirect_to('/login')
    end


    # it "should check filter for Orders" do
    #   FilterEntry.should_receive(:find).once.and_return( @filter_entries )
    #   Order.should_receive(:filter).once.with( @filter_entries ).and_return( Order )
    #   get :index
    #   response.should be_success
    # end
    # 
    # it "should get index and Order should receive filter" do
    #   # Order.should_receive( :filter ).once.and_return( Order )
    #   get :index
    #   response.should be_success
    # end

    it "should get index and Order should receive new_search" do
      Order.should_receive( :paginate ).once.and_return( @orders )
      get :index
      response.should be_success
    end

    it "should get index with user_id and assign user" do
      User.should_receive(:find).at_least(:twice).and_return( @user )
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
