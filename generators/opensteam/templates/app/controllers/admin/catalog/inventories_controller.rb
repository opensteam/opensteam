class Admin::Catalog::InventoriesController < Admin::CatalogController

  Inventory = Opensteam::Models::Inventory

  before_filter :set_product, :only => :index
  before_filter :set_filter

  # GET /admin/catalog/:product_type/:product_id/inventories
  # GET /admin/catalog/:product_type/:product_id/inventories?format=xml
  def index
    @product = context
    @inventories = @product.inventories #.new_search.all #filter( @filters ).paginate( :page => params[:page], :per_page => params[:per_page] || 20 )

    respond_to do |format|
      format.html {}
      format.js   { render :partial => "inventories", :object => @inventories, :layout => false }
      format.xml  { render :xml => @inventories.to_xml( :root => "inventories" ) }
    end
  end


  # GET /admin/catalog/:product_type/:product_id/inventories/:id/edit
  def edit
    @inventory = Inventory.find( params[:id], :include => :product )
    @product = @inventory.product
  end


  # PUT /admin/catalog/:product_type/:product_id/inventories/:id
  def update
    @inventory = Inventory.find( params[:id], :include => :product )
    @product = @inventory.product

    respond_to do |format|
      if @inventory.update_attributes( params[:inventory] )
        flash[:notice] = 'Inventory was successfully updated!'
        format.html { redirect_to( [:admin, :catalog, @inventory.product, :inventories] ) }
        format.xml  { head :ok }
      else
        format.html { render :action => :edit }
        format.xml  { render :xml => @inventory.errors, :status => :unprocessable_entity }
      end
    end

  end

  private

  # returns the product_id
  # /:product_type/:product_id/inventories
  def context_id
    params[:product_type] && params["#{ params[:product_type].to_s.singularize }_id"]
  end

  # returns the product model
  # /:product_type/:product_id/inventories
  # # => ProductType
  def context_model
    params[:product_type] && params[:product_type].to_s.classify.constantize
  end

  # returns the product
  def context *finder_options
    context_model.find( context_id, *finder_options )
  end

  # set @product instance variable
  def set_product
    @product = context( :include => :inventories )
  end


end
