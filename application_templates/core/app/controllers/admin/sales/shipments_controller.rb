class Admin::Sales::ShipmentsController < Admin::SalesController
  

  before_filter :set_filter
    
    
  def index
    @shipments = Opensteam::Models::Shipment.filter( @filters )
    
    if params[:order_id]
      @order = Opensteam::Models::Order.find( params[:order_id] )
      @shipments = ( @shipments || Opensteam::Models::Shipment ).by_order( params[:order_id] )
    end
    
    @shipments = @shipments.order_by( _s.sort, _s.dir ).paginate( :page => _s.page, :per_page => _s.per_page, :include => :order )  
    @total_entries = @shipments.total_entries
    
    respond_to do |format|
      format.html { @order ? render( :action => :index_order )  : render( :action => :index ) }
      format.xml  { render :xml => @shipments.to_ext_xml( :total_entries => @total_entries ) }
    end
    
  end
  
  def show
    @shipment = Opensteam::Models::Shipment.find( params[:id], :include => :order )
    @order = @shipment.order

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @shipment.to_xml( :root => 'shipment') }
    end
  end
  
  
  def new
    @order = Order.find( params[:order_id] )
    @shipment = @order.shipments.build do |s|
      s.address = @order.shipping_address
      s.shipping_rate = @order.shipping_rate
    end
    
    if @order.items.all_shipped?
      flash[:error] = "Cannot create shipment :  All order-items have been shipped!!"
      redirect_to request.referer
    end

  end
  
  
  
  def create
    @order = Opensteam::Models::Order.find( params[:shipment].delete( :order_id) )
    @shipment = @order.shipments.new( params[:shipment] )
    @address = @shipment.address
    
    unless params[:order_items]
      flash[:error] = "You have to select order-items first!"
      redirect_to :action => :new
      return
    end
  
    @shipment.items << @order.items.find( params[:order_items] )

    ret = @address.update_attributes( params[:address] ) && @shipment.save

    respond_to do |format|
      if ret
        flash[:notice] = 'Shipment was successfully created.'
        format.html { redirect_to( admin_sales_order_shipments_path( @order ) ) }
        format.xml  { render :xml => @shipment, :status => :created, :location => @shipment }
      else
        format.html { render :action => :new }
        format.xml  { render :xml => @shipment.errors, :status => :unprocessable_entity }
      end
    end
    
  end
  
  def update
    @shipment = Opensteam::Models::Shipment.find( params[:id] )

    respond_to do |format|
      if @shipment.update_attributes( params[:shipment] )
        format.html { redirect_to( admin_sales_order_path( @shipment.order ) ) }
        format.xml { head :ok }
      else
        format.html { render :action => "show" }
        format.xml { render :xml => @shipment.errors, :status => :unprocessable_entity }
      end
    end
 

  end
  
  private
  def set_sort_column
    id = params[:sort] || "id"
    @sort_column = Opensteam::Models::Shipment.osteam_configtable.columns.find { |s| s.id.to_s == id }
  end
  
  
   
end
