## TEMPLATE ##
class Admin::Catalog::PropertiesController < Admin::CatalogController
  before_filter :validate_sti_klass, :only => [ :new, :create ]
  
  def index_products
    @context = Product.send( *( params[:product_id] ? [:find, params[:product_id] ] : [:new] ) )
    index_with_context
  end
  
  def index_property_groups
    @context = PropertyGroup.send( *(params[:property_group_id] ? [:find, params[:property_group_id] ] : [:all] ) )
    index_with_context
  end
  
  def index_with_context
    @filters = parse_ext_filter
    @properties = Property.filter( @filters ).order_by( _s.sort, _s.dir ).paginate( :page => _s.page, :per_page => _s.per_page )
    
    respond_to do |format|
      format.extxml { render :action => :index2 }
    end
  end

  private :index_with_context
  

  
  def index
    if params[:product_id]
      @product = Product.find( params[:product_id], :include => [ { :property_groups => :properties }, :properties ] )
      @properties = @product.properties.order_by( _s.sort, _s.dir ).paginate( :page => _s.page, :per_page => _s.per_page )
    elsif params[:property_group_id]
      @property_group = PropertyGroup.find( params[:property_group_id], :include => :properties )
      @properties = @property_group.properties.order_by( _s.sort, _s.dir ).paginate( :page => _s.page, :per_page => _s.per_page )
    elsif params[:inventory_id]
      @inventory = Inventory.find( params[:inventory_id], :include => [ :properties, :product] )
      @properties = @inventory.properties.order_by( _s.sort, _s.dir ).paginate( :page => _s.page, :per_page => _s.per_page )
    else
      @properties = Property.order_by( _s.sort, _s.dir ).paginate( :page => _s.page, :per_page => _s.per_page )
    end

    @total_entries = @properties.total_entries

    respond_to do |format|
      format.html
      format.extxml
      format.json { 
        @property_json = build_tree_json
        render :json => @property_json.to_json
      }
    end
  end
  
  
  def new
    @property = Property.new
  end
  
  def create
    @property = @property_klass.new( params[:property] )
    respond_to do |format|
      if @property.save
        format.html {
          flash[:notice] = "Successfully created new Property!"
          redirect_to :action => :index
        }
      else
        format.html {
          flash[:error] = "Error: Could not create Property"
          render :action => :new
        }
      end
      
    end
  end
  
  
  def show
    @property = Property.find( params[:id] )
    render :action => :edit
  end
  
  def edit
    @property = Property.find( params[:id] )
  end
  
  
  def update
    @property = Property.find( params[:id] )
    
    if @property.update_attributes( params[:property] )
      flash[:notice] = "Successfully updated Property #{@property.id}"
      redirect_to :action => :index
    else
      flash[:error] = "Error updating Property #{@property.id}"
      render :action => :edit
    end
  end
  
  
  
  
  private

  
  
  def validate_sti_klass
    if params[:klass]
      @property_klass = params[:klass].classify.constantize
      unless @property_klass < Property
        @property = Property.new
        @property.errors.add( :type, "'#{params[:klass]} is not a Property-Class, 'doh" )
        render :action => :new
        return false
      end
    else
      @property_klass = Property
      return true
    end
  end
  
  
    
end
