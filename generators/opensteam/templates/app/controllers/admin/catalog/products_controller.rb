## TEMPLATE ##
class Admin::Catalog::ProductsController < Admin::CatalogController
  def index
    @products = AdminController.find_product_tables #AdministrationController.find_products.collect(&:class).uniq
  end
  
end
