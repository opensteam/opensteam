class AccountsController < ApplicationController
  layout 'account'

  
  before_filter :find_user, :except => [ :new, :create, :activate ]
  before_filter :check_current_user, :only => [ :new, :create, :activate ]

  def new
    @user = User.new
  end


  def create
    logout_keeping_session!
    @user = User.new(params[:user])
    @user.register! if @user && @user.valid?
    success = @user && @user.valid?
    if success && @user.errors.empty?
      redirect_back_or_default('/store')
      flash[:notice] = "Thanks for signing up!  We're sending you an email with your activation code."
    else
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
      render :action => 'new'
    end
  end

  def activate
    logout_keeping_session!
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && user && !user.active?
      user.activate!
      flash[:notice] = "Signup complete! Please sign in to continue."
      redirect_to '/login'
    when params[:activation_code].blank?
      flash[:error] = "The activation code was missing.  Please follow the URL from your email."
      redirect_back_or_default('/')
    else
      flash[:error]  = "We couldn't find a user with that activation code -- check your email? Or maybe you've already activated -- try signing in."
      redirect_back_or_default('/')
    end
  end



  
  def show
    @partial = "edit_info_fields"
    respond_to do |format|
      format.html
      format.js {
        render :update do |page|
          page.replace_html :account_content, :partial => "edit_info_fields"
        end
      }
    end
  end


  

  def update
    respond_to do |format|
      if @user.update_attributes( params[:user] )
        flash[:notice] = "Successfully save account information"
        format.html { redirect_to account_path }
      else
        flash[:error] = "Error saving account information"
        format.html { render :action => :index }#
      end
    end
  end





  def edit_password
    @partial = "edit_password_fields"
    respond_to do |format|
      format.html { render :action => :show }
      format.js {
        render :update do |page|
          page.replace_html :account_content, :partial => "edit_password_fields"
        end
      }
    end
  end


  def update_password
    user = User.authenticate( @user.login, params[:user][:old_password] )
    if user && user == @user
      params[:user].delete( :old_password )
      if @user.update_attributes( params[:user] )
        flash[:message] = "Successfully changed password!"
        redirect_to account_path
      else
        flash[:error] = "An error occured while trying to change your password..."
        render :action => 'edit_password'
      end
    else
      @customer.errors.add( :old_password, "Incorrect Old Password!")
      flash[:error] = "Incorrect Old Password"
      render :action => 'edit_password'
    end
  end



  private
  def find_user
    puts "**" * 100
    unless logged_in?
      store_location
      flash[:error] = "You're not logged in!"
      redirect_to login_path
      return false
    end
    @user = current_user
    return true
  end



  def check_current_user
    if logged_in?
      flash[:error] = "You are currently logged in! Please log out first!"
      redirect_to account_path
      return false
    end
    return true
  end


end