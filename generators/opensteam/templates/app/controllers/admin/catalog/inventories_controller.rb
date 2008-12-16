class Admin::Catalog::InventoriesController < Admin::CatalogController

  Inventory = Opensteam::Models::Inventory

  before_filter :set_product, :only => :index
  before_filter :set_filter

  # GET /admin/catalog/:product_type/:product_id/inventories
  # GET /admin/catalog/:product_type/:product_id/inventories?format=xml
  def index
    @product = context

    @inventories = @product.inventories.filter(@filters).order_by( _s.sort, _s.dir ).paginate( :page => _s.page, :per_page => _s.per_page, :include => :properties )
    @total_entries = @inventories.total_entries
    
    respond_to do |format|
      format.html { }
      format.js   { render :partial => "inventories", :object => @inventories, :layout => false }
      format.xml  
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




end
