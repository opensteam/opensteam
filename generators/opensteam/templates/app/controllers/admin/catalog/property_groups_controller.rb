class Admin::Catalog::PropertyGroupsController < Admin::CatalogController

  # GET /admin/catalog/:product_type/:product_id/property_groups
  # GET /admin/catalog/:product_type/:product_id/property_groups?format=xml
  def index
    @product = context( :include => :property_groups )
    @property_groups = @product.property_groups
    
    respond_to do |format|
      format.html { }
      format.xml { render :xml => @property_groups }
    end
  end


  def new
    @product = Product.find( params[:product_id] )
    @property_group = @product.property_groups.build
  end
  

  def edit
    @property_group = PropertyGroup.find( params[:id], :include => :product )
    @product = @property_group.product
  end
  


  # PUT /admin/catalog/:product_type/:product_id/inventories/:id
  def update
    @property_group = PropertyGroup.find( params[:id], :include => :product )
    @product = @property_group.product

    respond_to do |format|
      if @property_group.update_attributes( params[:property_group] )
        flash[:notice] = 'PropertyGroup was successfully updated!'
        format.html { redirect_to( admin_catalog_product_property_groups_path( @product ) ) }
        format.xml  { head :ok }
      else
        format.html { render :action => :edit }
        format.xml  { render :xml => @property_group.errors, :status => :unprocessable_entity }
      end
    end

  end




end
