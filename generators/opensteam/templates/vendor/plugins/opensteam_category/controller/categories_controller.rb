## TEMPLATE ##
class CategoriesController < Admin::CatalogController

  # GET /admin/catalog/categories
  # GET /admin/catalog/categories.xml
  # GET /admin/catalog/categories.json
  def index
    if params[:product_id]
      @product = Product.find( params[:product_id] )
      @categories = Category.root_nodes.collect { |c| c.to_hash( @product ) }
    else
            @categories = params[:node].to_i == 0 ? Category.root_nodes.collect(&:to_hash) : Category.find_children( params[:node] )
          end
          
    respond_to do |format|
      format.html { product_context? ? render( :action => :index_product ) : render( :action => :index ) }
      format.xml { render :xml => @categories }
      format.json { render :json => @categories }
    end
    
  end


  def new
    @category = Category.new
    @categories = Category.root_nodes.collect(&:to_hash)
  end

  def create
    @category = Category.new( params[:category] )
    params[:category][:products] ||= {}


    respond_to do |format|
      if @category.save
        @category.products << params[:category][:products].collect { |p| p.first.classify.constantize.find( p.last ) }
        format.html { redirect_to :action => :index }
        format.xml { head :ok }
        format.json { head :ok }
      else
        format.html { render :action => :new }
        format.xml
        format.json
      end
    end
  end


  # GET /admin/catalog/categories/:id/edit
  def edit
    @category = Category.find( params[:id] ) ;
    @products = Product.all
    @categories = Category.root_nodes.collect(&:to_hash)
  end


  # PUT /admin/catalog/categories/:id
  def update
    @category = Category.find( params[:id] ) ;
    params[:category][:products] ||= {}
    params[:category][:parent_id] = nil if params[:category][:parent_id].to_i == 0

    respond_to do |format|
      if @category.update_attributes( params[:category] )
        format.html { redirect_to :action => :index }
        format.xml { head :ok }
        format.json { head :ok }
      else
        puts 'error saving node'
      end



    end
  end

end