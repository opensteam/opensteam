class Admin::Config::TaxZonesController < Admin::ConfigController

  before_filter :set_filter


  def index
    @tax_zones = TaxZone.filter( @filters ).order_by( _s.sort, _s.dir ).paginate( :page => _s.page, :per_page => _s.per_page )
    @total_entries = @tax_zones.total_entries 

    respond_to do |format|
      format.html
      format.xml { render :xml => @tax_zones.to_ext_xml( :total_entries => @total_entries ) }
      format.js { render :partial => "admin/tax_zones/tax_zone_row", :collection => @tax_zones }
    end
    
    
  end
  
  
  def new
    @tax_zone = Opensteam::Money::Tax::TaxZone.new
    @countries = Opensteam::System::Zone.all.collect(&:country_name)
    
  end
  
  
  def create
    @tax_zone = Opensteam::Money::Tax::TaxZone.new( params[:tax_zone] )
    
    respond_to do |format|

      if @tax_zone.save
        flash[:notice] = "TaxZone was successfully created!"
        format.html { redirect_to :action => 'index' }
        format.xml { render :xml => @tax_zone.to_xml( :root => "tax_zone" ), :status => :creates, :location => @tax_zone }
      else
        format.html { render :action => 'new' }
        format.xml { render :xml => @tax_zone.errors, :status => :unprocessable_entity }
      end
      
    end
  end
  
  
  def show
    @tax_zone = Opensteam::Money::Tax::TaxZone.find( params[:id] )
    @countries = Zone.all.collect(&:country_name)
    
    respond_to do |format|
      format.html { render :action => 'edit' }
      format.xml { render :xml => @tax_zone.to_xml( :root => "tax_zone" ) }
    end
  end

  
  
  def edit
    @tax_zone = Opensteam::Money::Tax::TaxZone.find( params[:id] )
    @countries = Zone.all.collect(&:country_name)
  end

  
  
  def update
    @tax_zone = Opensteam::Money::Tax::TaxZone.find( params[:id] )
    
    respond_to do |format|
      if @tax_zone.update_attributes( params[:tax_zone] )
        flash[:notice] = "TaxZone was sucessfully updated!"
        format.html { redirect_to( admin_config_tax_zone_path( @tax_zone ) ) }
        format.xml { head :ok }
      else
        format.html { render :action => 'edit' }
        format.xml  { render :xml => @tax_zone.errors, :status => :unprocessable_entity }
      end
  
    end
  end

  
  def destroy
    @tax_zone = Opensteam::Tax::TaxZone.find( params[:id] )
    @tax_zone.destroy
    
    respond_to do |format|
      format.html { redirect_to( admin_config_tax_zones_path ) }
      format.xml { head :ok }
    end
  end

 

  
    
  
end