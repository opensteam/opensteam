## TEMPLATE ##
class Admin::System::QuicksteamsController < Admin::SystemController
  
  
  def index
    @quicksteams = current_user.quick_steams
    
    respond_to do |format|
      format.html
    end
  end

  def show
    @quicksteam = current_user.quick_steams.find( params[:id] )
    render :action => :edit
  end
  
  def edit
    @quicksteam = current_user.quick_steams.find( params[:id] )
  end
  
  def order
    @quicksteams = current_user.quick_steams
    params[:tabs].each_with_index { |t,i| @quicksteams.find(t).update_attributes( :position => i ) }
    render :partial => "admin/_header/tabs"
  end
  
  
  def create
    @quicksteam = Opensteam::System::QuickSteam.new( params[:quicksteam] )
    @quicksteam.user = current_user
    @cuicksteam.position = current_user.quick_steams.empty? ? 1 : current_user.quick_steams.sort.last.position + 1
    
    respond_to do |format|
      if @quicksteam.save
        format.html { redirect_to :action => :index }
        format.js
      end
    end
    
  end
  
  
  def update
    @quicksteam = current_user.quick_steams.find( params[:id] )
    @field = params[:quicksteam].keys.first
    respond_to do |format|
      if @quicksteam.update_attributes( params[:quicksteam] )
        flash[:notice] = "Successfully saved quickSteam"
        format.html { redirect_to admin_system_quicksteams_path }
        format.js
      end
    end
  end
  
  def destroy
    @quicksteam = Opensteam::System::QuickSteam.find( params[:id] )
    @quicksteam.destroy
    
    respond_to do |format|
      format.html { redirect_to :action => :index }
      format.xml  { head :ok }
      format.js   { head :ok }
    end
  end
  
  
  
end
