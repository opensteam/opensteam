class Account::OrdersController < AccountController

  include AuthenticatedSystem
  
  
  def index
    @orders = Order.by_user( @customer.id )
    
    if params[:state]
      if ( params[:state].collect(&:to_sym) - Order.available_states.collect(&:name).collect(&:to_sym) ).empty?
        @orders = @orders.scoped :conditions => { :state => params[:state] }
      end
    end
    
    @orders = ( @orders || Order ).order_by( @sort_column.order )
    
    if params[:sort]
      @orders.reverse! if session[:orders]
      session[:orders] = session[:orders] ? false : true
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @orders.to_xml( :root => 'orders' ) }
      format.js { render :partial => "order", :collection => @orders, :layout => false }
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
        format.html { redirect_to account_order_path( @order ) }
        format.xml { head :ok }
      else
        format.html { render :action => "show" }
        format.xml { render :xml => @order.errors, :status => :unprocessable_entity }
      end
    end
 

  end
    
 
end
