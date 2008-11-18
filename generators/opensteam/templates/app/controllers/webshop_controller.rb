## TEMPLATE ##
class <%= class_name %>Controller < ApplicationController
  
  include Opensteam::ShoppingCart
  include Authentication
  include AuthenticatedSystem
  include Opensteam::Finder
  	
  helper :all
  
  before_filter :delete_active_order
  
  

  
  # start the checkout-process
  #
  def start_checkout		
    redirect_to :controller => :checkout, :action => "invoke"
  end
	
	
  # index
  # show shop index (all products)
  def index
    #todo: implement paginate for find_products
    @products = Opensteam::Find.find_products
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @products }
    end
		
  end 

  
  
 
  

  # get inventory object for selected product and properties
  def inventory
    params[:product]  = frmt params[:product]

    
    if params[:product][:properties].index("")
      render :update do |page|
        page.replace_html :inventory, '<span style="color:red;">Please select a ' + params[:product][:properties].index("").singularize.humanize + '</span>'
      end
      return 
    else
      product = Opensteam::Find.find_product_with_inventory( params[:product] )
      @inventory = product.selected_inventories
    end
  
  end
  
  

  # show product-details
  def show
    unless @cart_details
      unless params[:id]
        @products = Opensteam::Find.find_product( params[:type] )
        respond_to do |format|
          format.html { render :action => :index }
          format.xml  { render :xml => @products }
        end
        return 
      end
      @product = Opensteam::Find.find_product_by_id( params[:type], params[:id] )
      @properties = @product.properties.to_h2 { |x| x.class.to_s.tableize }
      @inventory = @product.properties.empty? ? @product.inventories : []
    end
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @product }
    end
  end
	
  
  private
  def delete_active_order
    session[:active_order] = nil
  end
  


end
