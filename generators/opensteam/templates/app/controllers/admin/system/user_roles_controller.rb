class Admin::System::UserRolesController < Admin::SystemController



  def index
    @user_roles = UserRole.paginate( :page => params[:page],
      :per_page => params[:per_page] || 20, :order => "user_roles.id",
      :include => "users" )

    respond_to do |format|
      format.html
      format.xml { render :xml => @user_roles }
    end
  end


  def new
    @user_role = UserRole.new
  end

  
  def create
    @user_role = UserRole.new( params[:user_role] )

    respond_to do |format|
      if @user_role.save
        flash[:notice] = "Successfully saved UserRole #{@user_role.name}"
        format.html { redirect_to :action => :index }
        format.xml { head :ok }
      else
        flash[:error] = "Could not save UserRole"
        format.html { render :action => :new }
        
      end
    end
  end



  def edit
    @user_role = UserRole.find( params[:id] )

  end


  def update
    @user_role = UserRole.find( params[:id] )

    respond_to do |format|
      if @user.update_attributes( params[:user_role] )
        format.html { redirect_to :action => :index }
        format.xml { head :ok }
      else
        flash[:error] = "Could not update UserRole #{@user_role.name}"
        format.html { render :action => :edit }
      end
    end
  end


  def show
    @user_role = UserRole.find( params[:id] )
    respond_to do |format|
      format.html { render :action => :edit }
      format.xml { render :xml => @user_roles }
    end
  end


end
