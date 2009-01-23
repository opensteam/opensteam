class Admin::Catalog::ProductsController < Admin::CatalogController
  
  before_filter :validate_sti_klass, :only => [ :new, :create ]
  before_filter :set_filter
  
  def index
    @products = Product.filter( @filters ).order_by( _s.sort, _s.dir).paginate( :page => _s.page, :per_page => _s.per_page )
    @total_entries = @products.total_entries
        
    respond_to do |format|
      format.html
      format.xml
    end
  end
  
  
  def new
    @product = Product.new
    @all_properties = Property.all
  end
  
  
  def create
    @product = @product_klass.new( params[:product] )

    respond_to do |format|
      if @product.save
        @product.property_groups.build_for_properties && @product.save
        format.html { 
          flash[:info] = "Successfully created new Product"
          redirect_to admin_catalog_products_path }
      else
        format.html {
          @all_properties = Property.all
          flash[:error] = "Error: Could not create Product"
          render :action => :new }
      end
    end
  end

  
  
  def show
    @product = Product.find( params[:id], :include => [ { :inventories => :properties }, { :property_groups  => :properties } ] )
    @all_properties = Property.find( :all )
    render :action => :edit
  end
    
  def edit
    @product = Product.find( params[:id], :include => [ { :inventories => :properties }, { :property_groups  => :properties } ] )
    @all_properties = Property.find( :all )
  end
  
  def update
    @product = Product.find( params[:id], :include => [ { :inventories => :properties }, { :property_groups  => :properties } ] )
    
    
    params[:product][:property_ids] ||= []
    
    respond_to do |format|
      
      if @product.update_attributes( params[:product] )
        @product.property_groups.build_for_properties
        @product.save
        flash[:info] = "Product successfully saved!"
        format.html { redirect_to admin_catalog_product_path( @product ) }
      else
        flash[:error] = "Error: Could not save Product!"
        format.html { render :action => :edit }
      end
    end
  
  end
  
  private
  
  def validate_sti_klass
    if params[:klass]
      @product_klass = params[:klass].classify.constantize
      unless @product_klass < Product
        @product = Product.new
        @product.errors.add( :type, "'#{params[:klass]} is not a Product-Class, 'doh" )
        render :action => :new
        return false
      end
    else
      @product_klass = Product
      return true
    end
  end
  
end
