# CheckoutController
#
# Controller to handle the checkout-process
#
## TEMPLATE ##
require 'opensteam/shopping_cart'
require 'opensteam/checkout'


class CheckoutController < ApplicationController
  layout "<%= file_name %>"
  include Opensteam::Frontend::Checkout
  include Opensteam::Frontend::ShoppingCart
  
  before_filter :set_instance_vars
  
  
  def shipping_types
    locals = { :country => params[:order][:shipping_address][:country] }
    locals[:payment_type] = params[:order][:payment_type] if params[:order][:payment_type]

    
    render :update do |page|
      for st in Opensteam::Sales::ShipmentBase::RegionShippingRate.all.collect(&:shipping_method ).uniq
        page.replace_html "shipping_type_rate_#{st.underscore}", @cart.calculate_shipping_rate( 
          locals.update( :shipping_method => st ) )
      end
    end
    #    render :partial => "shipping_buttons", :locals => locals , :layout => false, :object => @cart
  end
  
  
  # initialize checkout-flow
  #
  def initialize
    create_checkout_flow do |c|
      c.on :start, :intro
      c.on :finish, :controller => "<%= file_name %>", :action => "index"
    end
  end
	
   
  def intro
    redirect_to :action => :new
  end
  
  
  def new
    @order = Order.new

    respond_to do |format|
      format.html
    end
  end


  
  def create
    @order = Order.new( params[:order] )
    
    @customer = logged_in? ? current_user : Opensteam::UserBase::User.new_or_existing_guest( params[:guest_customer] )
    @order.real_customer = @customer
    
    respond_to do |format|
      
      ret = @order.valid?
      @payment = Opensteam::Payment::Base[ @order.payment_type ].new( params[:payment_fields] ) if @order.payment_type
      ret2 = @payment.valid? if @order.payment_type
      
      if ret && ret2
        @order.save
        @order.copy_items_from @cart
        @order.update_price_and_tax!
        @order.set_shipping_rate!
        @order.save
        
        session[:active_order] = @order.id
        format.html { render :action => :show }
      else
        flash[:error] = "could not save order"
        format.html { render :action => :new }
      end
    end
    
  end
  
    
  def show
    @order = Order.find( session[:active_order],
      :include => [ :shipping_address, :payment_address, :items, :customer ] )
  end
  
  def place_order
    @order = Order.find( session[:active_order] )
    @order.customer.addresses << [ @order.shipping_address, @order.payment_address ]
    @order.payments.build_payment( params[:payment] )
    @order.save
    
    @order.state = :pending

    Mailer::OrderMailer.deliver_order_confirmation( @order )
    
    clear_cart
    redirect_to :action => :outro
  end
  
  
  
  def edit
    @order = Order.find( session[:active_order],
      :include => [ :shipping_address, :payment_address, :customer ] )
    
    @customer = @order.customer
  end
  
  
  def update
    @order = Order.find( session[:active_order] )
    @customer = @order.customer
    
    
    respond_to do |format|
      
      ret = @order.update_attributes( params[:order] )
      @payment = Opensteam::Payment::Base[ @order.payment_type ].new( params[:payment_fields] ) if ret

      if ret && @payment.valid?
       
        @order.update_price_and_tax!
        @order.set_shipping_rate!
        @order.save
        
        session[:active_order] = @order.id
        format.html { render :action => :show }
      else
        flash[:error] = "Error: Could not update order"
        format.html { render :action => :edit }
      end
    end
  end
  


  def outro
  end


  
  private
  
  
  def set_instance_vars
    @countries = Zone.all.collect(&:country_name).sort
    @customer = logged_in? ? current_user : User.new
    session[:return_to] = { :controller => 'checkout', :action => :new } unless logged_in?
    @addresses = @customer ? @customer.addresses : []
  end

	
	
end
