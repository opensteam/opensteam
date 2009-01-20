## TEMPLATE ##
class CartsController < ApplicationController
  
  layout "<%= file_name %>"
  
  before_filter :get_cart
  
  before_filter :check_availability, :only => [:create]
  before_filter :check_storage, :only => [:update]
  
  Cart = Opensteam::Container::Cart
  
  
  def check_availability
    if Inventory.find( params[:id] ).is_available?
      return true
    else
      render :update do |page| page.alert( "This Item is current not available!" ) end
      return false
    end
  end

  def check_storage
    if params[:incr]
      if ( @cart[ params[:id] ].quantity + 1 ) <= @cart[ params[:id].to_i ].item.storage
        return true
      else
        render :update do |page| page.alert( "Sorry, there are only #{@cart[ params[:id] ].item.storage} items available!") end
        return false
      end
    end
    
  end
  
  
  
  
  def index
  end
  
  
  def create
    @inventory = Inventory.find( params[:id] )
    @cart.push( @inventory )
    
    respond_to do |format|
      format.html { redirect_to :action => 'index' }
      format.js
    end
  end
   
  
  def show
    @inventory = @cart[ params[:id] ].item
    @product = @inventory.product
    @product.selected_inventory = @inventory
    @property_groups = @inventory.properties.collect { |p| PropertyGroup.new( :selector => "select", :selector_text => "Selected #{p.class}", :name => p.class, :properties => [ p ] ) }
    
    @inventory = [ @inventory ] # TODO: change webshop/show template ...
    
    @cart_details = true

    render :template => "<%= file_name %>/show"

  end
  
  
  def destroy
    if params[:id]
      @cart[ params[:id].to_i ].destroy
      @cart.reload
    else
      wipe_cart
    end
    

    respond_to do |format|
      format.html { redirect_to :action => 'index' }
      format.js { render :template => "carts/create.rjs" }
    end
    
  end
  
  
  def update
    if params[:id]
      @cart[ params[:id].to_i ].incr if params[:incr]
      @cart[ params[:id].to_i ].decr if params[:decr]
    end
    
    if params[:quantity]
      @cart.update_attributes( :set_quantity => Hash[ params[:quantity] ] )
    end 
    
    @cart.reload
    
    respond_to do |format|
      format.html { redirect_to shop_index_path  }
      format.js
    end
    
  end

  
  private
  def get_cart
    session[:cart] ||= Cart.create.id
    @cart = Cart.find( session[:cart] )
  end
  
  def wipe_cart
    session[:cart] = nil
    get_cart
  end


  
end
