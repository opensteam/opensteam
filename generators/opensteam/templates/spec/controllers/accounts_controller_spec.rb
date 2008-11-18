require File.dirname(__FILE__) + '/../spec_helper'
  
# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead
# Then, you can remove it from this and the units test.
include AuthenticatedTestHelper

describe AccountsController do
  fixtures :users


  it "should redirect to account path if logged_in on signup" do
    @user = User.authenticate('quentin', 'monkey')
    request.session[:user_id] = @user.id
    get :new
    response.should be_redirect
    response.should redirect_to account_path

    flash[:error ].should_not be_nil
  end


  
  it "should redirect to account_path if logged_in on create" do
    lambda do
      @user = User.authenticate('quentin', 'monkey')
      request.session[:user_id] = @user.id
      create_user
      response.should be_redirect
      response.should redirect_to account_path
      flash[:error].should_not be_nil
    end.should_not change(User, :count)
  end

  

  it 'allows signup' do
    lambda do
      create_user
      response.should be_redirect
    end.should change(User, :count).by(1)
  end

  
  it 'signs up user in pending state' do
    create_user
    assigns(:user).reload
    assigns(:user).should be_pending
  end

  it 'signs up user with activation code' do
    create_user
    assigns(:user).reload
    assigns(:user).activation_code.should_not be_nil
  end
  it 'requires login on signup' do
    lambda do
      create_user(:login => nil)
      assigns[:user].errors.on(:login).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end
  
  it 'requires password on signup' do
    lambda do
      create_user(:password => nil)
      assigns[:user].errors.on(:password).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end
  
  it 'requires password confirmation on signup' do
    lambda do
      create_user(:password_confirmation => nil)
      assigns[:user].errors.on(:password_confirmation).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end

  it 'requires email on signup' do
    lambda do
      create_user(:email => nil)
      assigns[:user].errors.on(:email).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end
  
  
  it 'activates user' do
    User.authenticate('aaron', 'monkey').should be_nil
    get :activate, :activation_code => users(:aaron).activation_code
    response.should redirect_to('/login')
    flash[:notice].should_not be_nil
    flash[:error ].should     be_nil
    User.authenticate('aaron', 'monkey').should == users(:aaron)
  end
  
  it 'does not activate user without key' do
    get :activate
    flash[:notice].should     be_nil
    flash[:error ].should_not be_nil
  end
  
  it 'does not activate user with blank key' do
    get :activate, :activation_code => ''
    flash[:notice].should     be_nil
    flash[:error ].should_not be_nil
  end
  
  it 'does not activate user with bogus key' do
    get :activate, :activation_code => 'i_haxxor_joo'
    flash[:notice].should     be_nil
    flash[:error ].should_not be_nil
  end
  
  def create_user(options = {})
    post :create, :user => { :login => 'quire', :email => 'quire@example.com',
      :password => 'quire69', :password_confirmation => 'quire69' }.merge(options)
  end
end

describe AccountsController do
  describe "route generation" do
    it "should route account's 'index' action correctly" do
      route_for(:controller => 'accounts', :action => 'show').should == "/account"
    end
    
    it "should route account's 'new' action correctly" do
      route_for(:controller => 'accounts', :action => 'new').should == "/signup"
    end
    
    it "should route {:controller => 'accounts', :action => 'create'} correctly" do
      route_for(:controller => 'accounts', :action => 'create').should == "/register"
    end
    
    it "should route accounts 'edit_password' action correctly" do
      route_for(:controller => 'accounts', :action => 'edit_password' ).should == "/account/edit_password"
    end
    
    it "should route account's 'update' action correctly" do
      route_for(:controller => 'accounts', :action => 'update' ).should == "/account"
    end
    
    it "should route account's 'destroy' action correctly" do
      route_for(:controller => 'accounts', :action => 'destroy' ).should == "/account"
    end
  end
  
  describe "route recognition" do
    it "should generate params for account's index action from GET /account" do
      params_from(:get, '/account').should == {:controller => 'accounts', :action => 'show'}
      #     params_from(:get, '/users.xml').should == {:controller => 'users', :action => 'index', :format => 'xml'}
      #     params_from(:get, '/users.json').should == {:controller => 'users', :action => 'index', :format => 'json'}
    end
    
    it "should generate params for account's new action from GET /account" do
      params_from(:get, '/account/new').should == {:controller => 'accounts', :action => 'new'}
      #    params_from(:get, '/users/new.xml').should == {:controller => 'users', :action => 'new', :format => 'xml'}
      #    params_from(:get, '/users/new.json').should == {:controller => 'users', :action => 'new', :format => 'json'}
    end
    
    it "should generate params for account's create action from POST /account" do
      params_from(:post, '/account').should == {:controller => 'accounts', :action => 'create'}
      #    params_from(:post, '/users.xml').should == {:controller => 'users', :action => 'create', :format => 'xml'}
      #    params_from(:post, '/users.json').should == {:controller => 'users', :action => 'create', :format => 'json'}
    end
    
    it "should generate params for account's edit action from GET /account/edit_password" do
      params_from(:get , '/account/edit_password').should == {:controller => 'accounts', :action => 'edit_password' }
    end
    
    it "should generate params {:controller => 'accounts', :action => update' } from PUT /account" do
      params_from(:put , '/account').should == {:controller => 'accounts', :action => 'update'}
      #     params_from(:put , '/users/1.xml').should == {:controller => 'users', :action => 'update', :id => '1', :format => 'xml'}
      #     params_from(:put , '/users/1.json').should == {:controller => 'users', :action => 'update', :id => '1', :format => 'json'}
    end
    
    #    it "should generate params for users's destroy action from DELETE /users/1" do
    #      params_from(:delete, '/users/1').should == {:controller => 'users', :action => 'destroy', :id => '1'}
    #      params_from(:delete, '/users/1.xml').should == {:controller => 'users', :action => 'destroy', :id => '1', :format => 'xml'}
    #      params_from(:delete, '/users/1.json').should == {:controller => 'users', :action => 'destroy', :id => '1', :format => 'json'}
    #    end
  end
  
  describe "named routing" do
    before(:each) do
      get :new
    end
    
    it "should route account_path() to /account" do
      account_path().should == "/account"
      #      formatted_users_path(:format => 'xml').should == "/users.xml"
      #      formatted_users_path(:format => 'json').should == "/users.json"
    end
    
    it "should route new_user_path() to /account/new" do
      new_account_path().should == "/account/new"
      #     formatted_new_user_path(:format => 'xml').should == "/users/new.xml"
      #     formatted_new_user_path(:format => 'json').should == "/users/new.json"
    end
    
    it "should route edit_password_account_path to /account/edit_password" do
      edit_password_account_path.should == "/account/edit_password"
      #      formatted_user_path(:id => '1', :format => 'xml').should == "/users/1.xml"
      #      formatted_user_path(:id => '1', :format => 'json').should == "/users/1.json"
    end
    
  end
  
end
