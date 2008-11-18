## TEMPLATE ##
class Admin::System::QuicksteamsController < Admin::SystemController
  
  
  def create
    @quicksteam = QuickSteam.new( params[:quicksteam] )
    
    respond_to do |format|
      if @quicksteam.save
        format.any { head :ok }
      end
    end
    
  end
  
  
  
end
