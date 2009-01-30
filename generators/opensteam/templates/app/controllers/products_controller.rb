class ProductsController < OpensteamController
  helper :all
  
  
  before_filter :find_categories
  before_filter :delete_active_order
  
  # start the checkout-process
  #
  def checkout		
    redirect_to :controller => :checkout, :action => "invoke"
  end
	
	
  # index
  # show shop index (all products)
  def index
    @products = Product.paginate( :page => params[:page] || 1, :per_page => params[:per_page] || 10 ) 

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @products }
    end
	end 

  
  def inventory
    @properties = Property.find( params[:product][:selected_properties].values )
    @product = Product.find( params[:id] )
    @inventory = @product.inventories( @properties )
    respond_to do |format|
      format.html { render :text => @inventory.to_yaml }
      format.xml  { render :xml => @inventory }
      format.js
    end
  end
  
  
  def show
    unless @cart_details
      @product = Product.find( params[:id], :include => [ :properties, :property_groups ] )
      @property_groups = @product.property_groups
      @inventory = @product.inventories if @product.inventories.size == 1 
    end
    
    respond_to do |format|
      format.html
      format.xml { render :xml => @product, :head => :ok }
    end
  end


  private
  
  
  def find_categories
    @categories = Category.root_nodes( :all, :include => :products ).active
  end
  

  def delete_active_order
    session[:active_order] = nil
  end

end
