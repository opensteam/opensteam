class Admin::System::UsersController < Admin::SystemController

  before_filter :set_filter



  require_role :customer, :except => [:new]

  def index

    @users = User.filter( @filters )
    
    @users = @users.paginate( :page => params[:page],
      :include => :user_roles,
      :per_page => params[:per_page] || 20, :order => "users.id" )

  end



  def new
    @user = User.new
  end

  def create
    @user = User.new

    params[:roles] ||= []

    respond_to do |format|
      if @user.register!
        @user.user_role_ids = params[:roles].collect(&:to_i) if params[:roles]
        @user.save
        @user.activate! if params[:activate]
        flash[:notice] = "Successfully saved User"
        format.html { redirect_to :action => :index }
        format.xml { head :ok }
      else
        flash[:error] = "Error: Could not save User"
        format.html { render :action => :new }
        format.xml { }
      end
    end

  end

  def update
    @user = User.find( params[:id] )

    params[:roles] ||= []
        
    respond_to do |format|
      if @user.update_attributes( params[:user] )
        @user.user_role_ids = params[:roles].collect(&:to_i) if params[:roles]
        @user.save
        flash[:notice] = "Successfully saved User"
        format.html { redirect_to :action => :index }
        format.xml { head :ok }
      else
        flash[:error] = "Error: Could not save User"
        format.html { render :action => :edit }
        format.xml { }
      end
    end
  end

  def send_event
    @user = User.find( params[:id] )

    if @user.aasm_events_for_current_state.include?( params[:event].to_sym )
        puts "INNER" * 100
      @user.send( "#{params[:event]}!" )
    end

    redirect_to :action => :index
  end

  def show
    @user = User.find( params[:id] )

    respond_to do |format|
      format.html { render :action => :edit }
      format.xml
    end
  end





end
