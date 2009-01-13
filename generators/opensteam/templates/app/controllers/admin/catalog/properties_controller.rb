## TEMPLATE ##
class Admin::Catalog::PropertiesController < Admin::CatalogController
  before_filter :validate_sti_klass, :only => [ :new, :create ]
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
      format.xml
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
  def build_tree_json
    property_hash = lambda { |p| { :id => p.id, :expanded => true, :text => "Property: #{p.class} - #{p.value}", :children => [] } }
    @property_groups = @product.property_groups
    @property_groups.collect { |pg|
      {:leaf => false,  :iconCls => 'tree-folder-icon', :id => "group_#{pg.id}", :checked => false, :expanded => true, :text => "GROUP: #{pg.name}",
        :children => pg.properties.collect(&property_hash)
      }
    } + 
    @product.properties.collect(&property_hash)
  end
  
  
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
