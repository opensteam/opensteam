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

    @orders = @orders.order_by( _s.sort, _s.dir ).paginate( :per_page => _s.per_page, :page => _s.page )
    @total_entries = @orders.total_entries
    
    respond_to do |format|
      format.html
      format.xml { render :xml => @orders.to_ext_xml( :total_entries => @total_entries ) }
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
