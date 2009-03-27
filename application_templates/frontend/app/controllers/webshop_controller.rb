## TEMPLATE ##
class <%= class_name %>Controller < OpensteamController
  
  include Opensteam::Frontend::ShoppingCart
  include Authentication
  include AuthenticatedSystem
  	
  helper :all
  
  before_filter :delete_active_order
  
  

  
  # start the checkout-process
  #
  def checkout		
    redirect_to :controller => :checkout, :action => "invoke"
  end
	
	
  # index
  # show shop index (all products)
  def index
    @products = Product.all
    # 
    # 
    # #todo: implement paginate for find_products
    # @products = Opensteam::Find.find_products
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @products }
    end
		
  end 

  
  
 
  

  # get inventory object for selected product and properties
  def inventory
    puts params[:product].inspect
    @properties = Property.find( params[:product][:selected_properties].values )
    @product = Product.find( params[:product][:id] )
    @inventory = @product.inventories( @properties )
  end
  
  
  def show
    unless @cart_details
      @product = Product.find( params[:id], :include => [ { :property_groups => :properties }, :properties ] )
      @property_groups = @product.property_groups
      @inventory = @product.inventories if @product.inventories.size == 1 
    end
  end
    
    
  

  # show product-details
  def show2
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
