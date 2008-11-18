class Admin::Sales::OrdersController < Admin::SalesController
  helper :all
  before_filter :set_per_page
  before_filter :set_filter



  def index
    @orders = Order.filter( @filters )

    if params[:user_id]
      @customer = User.find( params[:user_id])
      @orders = @orders.by_user( @customer.id ) if @customer
    end

    @orders = @orders.paginate( :page => params[:page],
      :per_page => params[:per_page] || 20,
      :include => [ :customer, :shipping_address, :payment_address ],
      :order => "containers.id" )
      
    respond_to do |format|
      format.html
      format.xml { render :xml => @orders.to_xml( :root => "orders" ) }
      format.js { render :update do |page|
          page.replace_html :grid, :partial => "orders", :object => @orders
          page.replace_html :filter, :partial => "admin/filters/filter", :locals => { :records => @orders, :model => "Order" }
        end
      } 
    end
      
  end

  
  def show
    @order ||= Order.find( params[:id] )

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @order }
    end
  end

  
  
  
  def update
    @order = Order.find( params[:id] )

    respond_to do |format|
      if @order.update_attributes( params[:order] )
        format.html { redirect_to admin_order_path( @order ) }
        format.xml { head :ok }
      else
        format.html { render :action => "show" }
        format.xml { render :xml => @order.errors, :status => :unprocessable_entity }
      end
    end
 

  end
  
  
  private
  def set_per_page
    params[:page] = 1 unless params[:page]
  end
 
end
