class Admin::CatalogController < AdminController
  
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
    Product.find( params[:product_id], *finder_options )
#    context_model.find( context_id, *finder_options )
  end

  # set @product instance variable
  def set_product
    @product = Product.find( params[:product_id], :include => :inventories )
#    @product = context( :include => :inventories )
  end
  
  # check if controller has a product_context
  #  => checks if params[:product_type] and params[ "#{params[:product_type]}_id"] are set
  def product_context?
    params[:product_id] && true
  end
  
  def parse_ext_filter
    if params[:ext_filter]
      checked = params[:ext_filter].select { |s| s.last[:field].include?( "checked" ) }.flatten.last
      unless checked.empty?
        checked[:field] = @context.class.to_s.tableize
        checked[:data][:comparison] = checked[:data][:value] == "true" ? "=" : "!="
        checked[:data][:value] = @context.id.to_s
      end

      return params[:ext_filter].collect { |f| 
        Opensteam::Helpers::Grid::FilterEntry.create( :key => f.last[:field], :val => f.last[:data][:value], :op => f.last[:data][:comparison] || "LIKE" ) 
      }
    end
    return []
  end
  
end
