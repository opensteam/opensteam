## TEMPLATE ##
class Admin::Catalog::<%= class_name.pluralize %>Controller < AdminController
  include Opensteam::Finder

  before_filter :set_filter


  # GET /<%= table_name %>
  # GET /<%= table_name %>.xml
  def index
    @<%= table_name %> = <%= class_name %>.filter( @filters )
    @<%= table_name %> = @<%= table_name %>.paginate( :page => _s.page,
      :per_page => _s.per_page )

    @total_entries = @<%= table_name %>.total_entries

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @<%= table_name %>.to_ext_xml( :total_entries => @total_entries ) }
    end
  end

  # GET /<%= table_name %>/1
  # GET /<%= table_name %>/1.xml
  def show
    @<%= file_name %> = <%= class_name %>.find(params[:id], :include => { :inventories => :properties } )
    @properties = <%= class_name %>.get_has_property
    @inventories = @<%= file_name %>.inventories
    respond_to do |format|
      format.html { render :action => :edit }
    format.xml  { render :xml => @<%= file_name %> }
    end
  end

  # GET /<%= table_name %>/new
  # GET /<%= table_name %>/new.xml
  def new
    @<%= file_name %> = <%= class_name %>.new
    
    @properties = <%= class_name %>.get_has_property
    @products = <%= class_name %>.get_has_products

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @<%= file_name %> }
    end
  end



  # GET /<%= table_name %>/1/edit
  def edit
    @<%= file_name %> = <%= class_name %>.find(params[:id])
		
    @properties = <%= class_name %>.get_has_property
    @products = <%= class_name %>.get_has_products

				
  end

  # POST /<%= table_name %>
  # POST /<%= table_name %>.xml
  def create
    params[:<%= file_name %>][:set_properties] = {} unless params[:<%= file_name %>][:set_properties]
    
    @<%= file_name %> = <%= class_name %>.new(params[:<%= file_name %>])


    respond_to do |format|
      if @<%= file_name %>.save
        flash[:notice] = '<%= class_name %> was successfully created.'
        format.html { redirect_to( admin_catalog_<%= plural_name %>_path ) }
        format.xml  { render :xml => @<%= file_name %>, :status => :created, :location => @<%= file_name %> }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @<%= file_name %>.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /<%= table_name %>/1
  # PUT /<%= table_name %>/1.xml
  def update
    @<%= file_name %> = <%= class_name %>.find(params[:id])
    unless @<%= file_name %>.properties.empty?
      params[:<%= file_name %>][:set_properties] = {} unless params[:<%= file_name %>][:set_properties]
    end
    
    respond_to do |format|
      if @<%= file_name %>.update_attributes(params[:<%= file_name %>])
        flash[:notice] = '<%= class_name %> was successfully updated.'
        format.html { redirect_to( [:admin, :catalog, @<%= file_name %> ] ) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @<%= file_name %>.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /<%= table_name %>/1
  # DELETE /<%= table_name %>/1.xml
  def destroy
    @<%= file_name %> = <%= class_name %>.find(params[:id])
    @<%= file_name %>.destroy

    respond_to do |format|
      format.html { redirect_to(admin_catalog_<%= table_name %>_url) }
      format.xml  { head :ok }
    end
  end
end
