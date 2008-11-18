class Admin::Sales::ShipmentsController < Admin::SalesController
  

  before_filter :set_filter
    
    
  def index
    @shipments = Opensteam::Models::Shipment.filter( @filters )
    
    if params[:order_id]
      @order = Opensteam::Models::Shipment.find( params[:order_id] )
      @shipments = ( @shipments || Opensteam::Models::Shipment ).by_order( params[:order_id] )
    end
    
    @shipments = ( @shipments || Opensteam::Models::Shipment ).paginate(
     :page => params[:page],
     :per_page => params[:per_page] || 20,
     :include => [ :order ],
     :order => 'shipments.id' )
    
    respond_to do |format|
      format.html
      format.xml { render :xml => @shipments.to_xml( :root => 'shipments' ) }
      format.js {  render :update do |page|
       #   page.replace_html :grid, :partial => 'invoices', :object => @invoices 
        #  page.replace_html :filter, :partial => 'admin/filters/filter', :locals => { :records => @invoices, :model => 'Invoice' }
        end
      }
      
    end
    
  end
  
  def show
    @order = Order.find( params[:order_id] )
    @shipment ||= Opensteam::Models::Shipment.find( params[:id] )

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @shipments }
    end
  end
  
  
  def new
    @order = Order.find( params[:order_id] )
    @shipment = @order.shipments.build do |s|
      s.address = @order.shipping_address
      s.shipping_rate = @order.shipping_rate
    end
    
    if @order.items.all_shipped?
      flash[:error] = "Cannot create shipment :  All order items have been shipped!!"
      redirect_to admin_order_path( @order )
    end

  end
  
  
  
  def create
    @order = Order.find( params[:order_id] )
    @shipment = @order.shipments.new( params[:shipment] )
    @address = @shipment.address
    
    @order_items = @order.items.select { |o|
      params[:order_items].keys.include?( o.id.to_s ) && params[:order_items][ o.id.to_s ] == "1"
    }

    @shipment.order_items << @order_items
    
    ret = @address.update_attributes( params[:address] ) &&
      @shipment.save
    
    
    
    respond_to do |format|
      if ret
        flash[:notice] = 'Shipment was successfully created.'
        format.html { redirect_to( admin_sales_order_path( @order ) ) }
        format.xml  { render :xml => @shipment, :status => :created, :location => @shipment }
      else
        format.html { render :action => "new" }
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
