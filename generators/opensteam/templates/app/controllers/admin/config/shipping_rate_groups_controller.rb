class Admin::Config::ShippingRateGroupsController < Admin::ConfigController

  ShippingRateGroup = Opensteam::Sales::ShipmentBase::ShippingRateGroup

  def index
    @groups = ShippingRateGroup.find( :all, :include => [ :shipping_rates, :payment_additions ] )
  end
  
  
  def new
    @group = ShippingRateGroup.new
    
    respond_to do |format|
      format.html {}
    end
  end

  def edit
    @group = ShippingRateGroup.find( params[:id] )
    
    respond_to do |format|
      format.html {}
    end
  end
  
  
  def create
    @group = ShippingRateGroup.new( params[:group] )
    
    respond_to do |format|
      ret = @group.save
      if ret && @group.errors.empty?
        format.html { redirect_to :action => :index }
      else
        flash[:error] = "Could not save Group of ShippingRates"
        format.html { render :action => :new }
      end
      
    end
  end

  
  def update
    @group = ShippingRateGroup.find( params[:id] )
    
    params[:group][:existing_rates] ||= {}
    
    respond_to do |format|
      if @group.update_attributes( params[:group] )
        flash[:notice] = "Successfully updated ShippingRateGroup ##{@group.id}"
        format.html { redirect_to :action => :index }
      else
        flash[:error] = "Error: Could not update ShippingRateGroup ##{@group.id}"
        format.html { redirect_to :action => :edit }
      end
    end
  end
  
  
  def destroy
    @group = ShippingRateGroup.find( params[:id] )
    
    respond_to do |format|
      @group.destroy
      format.html { redirect_to :action => :index }
      format.xml { head :ok }
    end

  end
  
  
  
end