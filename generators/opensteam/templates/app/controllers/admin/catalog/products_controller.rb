class Admin::Catalog::ProductsController < Admin::CatalogController
  def index
    @products = AdminController.find_product_tables #AdministrationController.find_products.collect(&:class).uniq
  end
  
  def show
    @product = Opensteam::Product.find( params[:type], params[:id], :include => :inventories )
  end
    
  
  
end
