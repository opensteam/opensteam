## TEMPLATE ##
class Admin::Catalog::PropertiesController < Admin::CatalogController
  def index
    @properties = AdminController.find_property_tables
  end
  
end
