class Admin::Sales::InvoicesController < Admin::SalesController


  before_filter :set_filter

  def index
    @invoices = Opensteam::Models::Invoice.filter( @filters )

    if params[:order_id]
      @order = Order.find( params[:order_id] )
      @invoices = @order.invoices
    end
    
    @invoices = @invoices.order_by( _s.sort, _s.dir ).paginate( :per_page => _s.per_page, :page => _s.page )
    @total_entries = @invoices.total_entries
    
    respond_to do |format|
      format.html { @order ? render( :action => :index_order ) : render( :action => :index ) }
      format.xml  { render :xml => @invoices.to_ext_xml( :total_entries => @total_entries ) }
    end
  end
  
  
  def show
    @invoice ||= Opensteam::Models::Invoice.find( params[:id] )
    @order = @invoice.order

    respond_to do |format|
      format.html
      format.xml { render :xml => @invoice.to_xml( :root => 'invoice') }
      format.pdf {
        render :layout => false
        prawnto( :filename => "order_#{@order.id}_invoice_#{@invoice.id}", :prawn => { :page_size => 'A4' } )
      }
    end
  end
  
  
  def new
    @order = Order.find( params[:order_id] )

    if @order.items.all_invoiced?
      flash[:error] = "Cannot create invoice :  All order-items have an invoice!"
      redirect_to request.referer
    end

    @invoice = @order.invoices.new
  end
  
  
  
  
  
  def create
    unless params[:order_items]
      flash[:error] = "You have to select order-items to create an invoice!"
      redirect_to :action => :new
      return 
    end
    
    @order = Order.find( params[:invoice].delete( :order_id ) )
    @invoice = @order.invoices.new( params[:invoice] )
    @address = @invoice.address
    @invoice.items << @order.items.find( params[:order_items] )

    ret = @address.update_attributes( params[:address] ) && @invoice.save

    respond_to do |format|
      if ret
        flash[:notice] = 'Invoice was successfully created.'
        format.html { redirect_to( admin_sales_order_invoices_path( @order ) ) }
        format.xml  { render :xml => @invoice.to_xml( :root => 'invoice') , :status => :created, :location => @invoice }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @invoice.errors, :status => :unprocessable_entity }
      end
    end
    
  end
  

  def update_price
  
    @order = Order.find( params[:invoice][:order_id] )

    price = BigDecimal.new( 
      params[:order_items] ? 
        @order.items.find( params[:order_items] ).collect(&:total_price).sum.to_s :
        "0.0" 
    ) - BigDecimal.new( params[:invoice][:discount] )

    price += BigDecimal.new( params[:shipping_rate] ? @order.shipping_rate.to_s : "0.0" )
    
    render :update do |page|
      page["invoice_price"].highlight( :startcolor => '#D8E668' )
      page["invoice_price"].value = price
    end
    

  end


  
  
  
   
end
