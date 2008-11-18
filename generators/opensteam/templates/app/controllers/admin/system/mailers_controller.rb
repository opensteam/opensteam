class Admin::System::MailersController < Admin::ConfigController

  before_filter :set_filter
  
  def index
    #@filter_entries = FilterEntry.find( profile_session.active_filter( self ) )
    @orders = Opensteam::System::Mailer.filter( @filters )

    @mailers = ( @mailers || Opensteam::System::Mailer ).paginate( :page => params[:page],
      :per_page => params[:per_page] || 20
    ) ;

    respond_to do |format|
      format.html
      format.xml { render :xml => @mailers.to_xml( :root => "mailers" ) }
      format.js {
        render :update do |page|
          page.replace_html :grid, :partial => "mailers", :object => @orders
          page.replace_html :filter, :partial => "admin/filters/filter", :locals => { :records => @mailers, :model => "Admin::Config::Mailer" }
        end
      }
    end


  end


  def show
    @mailer = Opensteam::System::Mailer.find( params[:id] )
    respond_to do |format|
      format.html { render :action => :edit }
    end
  end

  def new
    @mailer = Opensteam::System::Mailer.new
    
    respond_to do |format|
      format.html { render :action => :edit }
    end
  end

  def edit
    @mailer = Opensteam::System::Mailer.find( params[:id] )
    
    respond_to do |format|
      format.html {}
    end
  end


  def create
    @mailer = Opensteam::System::Mailer.new( params[:admin_system_mailer] )
    respond_to do |format|
      if @mailer.save
        format.html { redirect_to :action => :index }
      else
        flash[:error] = "Could not save Mailer"
        format.html { render :action => :new }
      end
    end
  end
  
  
  def update
    @mailer = Opensteam::System::Mailer.find( params[:id] )
    respond_to do |format|
      if @mailer.update_attributes( params[:mailer] )
        flash[:notice] = "Successfully updated Mailer!"
        format.html { redirect_to :action => :index }
      else
        flash[:error] = "Error: Could not update Mailer!"
        format.html { render :action => :edit }
      end

    end
  end

  def destroy
    @destroy = Opensteam::System::Mailer.find( params[:id] )
    respond_to do |format|
      @mailer.destroy
      format.html { redirect_to :action => :index }
      format.xml { head :ok }
    end
  end

  
  
  
end