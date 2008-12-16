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
    context_model.find( context_id, *finder_options )
  end

  # set @product instance variable
  def set_product
    @product = context( :include => :inventories )
  end
  
  # check if controller has a product_context
  #  => checks if params[:product_type] and params[ "#{params[:product_type]}_id"] are set
  def product_context?
    context_id && true
  end
  
  
  
end
