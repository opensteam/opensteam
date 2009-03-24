class Admin::Config::TaxGroupsController < Admin::ConfigController

  def index

    @tax_groups = ProductTaxGroup.paginate( :all,
      :page => params[:page], :per_page => params[:per_page]
    )
   
    respond_to do |format|
      format.html
      format.xml { render :xml => @tax_groups.to_xml( :root => "tax_groups") }
      format.js { render :partial => "admin/tax_groups/tax_group", :collection => @tax_groups}
    end

  end
  
  
  def new
    @tax_group = Opensteam::Sales::Money::Tax::ProductTaxGroup.new
    @tax_zones = Opensteam::Sales::Money::Tax::TaxZone.all
  
    @tax_rules = @tax_group.tax_rules.build
  
  end


  
  
  
  def create
    @tax_group = Opensteam::Sales::Money::Tax::ProductTaxGroup.new( params[:tax_group] )
    @tax_zones = Opensteam::Sales::Money::Tax::TaxZone.all.to_h2 { |a| a.country }
    
    respond_to do |format|
      if @tax_group.save
        flash[:info] = "TaxGroup successfully created!"
        format.html { redirect_to :action => :index }
        format.xml { render :xml => @tax_group.to_xml( :root => "tax_group" ), :status => :created, :location => @tax_zone }
      else
        format.html { render :action => :new }
        format.xml { render :xml => @tax_group.errors, :status => :unprocessable_entity }
      end
    end
    
  end

  
  def show
    @tax_group = Opensteam::Sales::Money::Tax::TaxGroup.find( params[:id], :include => :tax_rules )
    @tax_zones = Opensteam::Sales::Money::Tax::TaxZone.all
    respond_to do |format|
      format.html { render :action => :edit }
      format.xml { render :xml => @tax_group.to_xml( :root => "tax_group" ) }
    end
  end
  
  
  def edit
    @tax_group = Opensteam::Sales::Money::Tax::TaxGroup.find( params[:id] )
    @tax_zones = Opensteam::Sales::Money::Tax::TaxZone.all
  end
  
  
  def update
    @tax_group = Opensteam::Sales::Money::Tax::ProductTaxGroup.find( params[:id] )
    @tax_zones = Opensteam::Sales::Money::Tax::TaxZone.all
    
    params[:tax_group][:existing_tax_rule_attributes] ||= {}
    
    respond_to do |format|
      if @tax_group.update_attributes( params[:tax_group] )
        flash[:info] = "TaxGroup successfully saved!"
        format.html { redirect_to admin_config_tax_group_path( @tax_group ) }
        format.xml { render :xml => @tax_group.to_xml( :root => "tax_group" ), :status => :created, :location => @tax_zone }
      else
        format.html { render :action => :edit }
        format.xml { render :xml => @tax_group.errors, :status => :unprocessable_entity }
      end
    end
    
  end
  
  

  def destroy
    @tax_group = Opensteam::Sales::Money::Tax::TaxGroup.find( params[:id] )
    
    respond_to do |format|
      unless @tax_group.inventories.empty?
        flash[:error] = "Cannot delete TaxGroup '#{@tax_group.name}'. Remove Product Associations first."
        format.html { redirect_to :action => :index }
      else
        @tax_group.destroy
        format.html { redirect_to :action => :index }
        format.xml { head :ok }
      end
      
    end
    
  end

    
  
end