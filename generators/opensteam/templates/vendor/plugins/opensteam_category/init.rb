## INIT opensteam_categories PLUGIN

require 'opensteam'
#require_dependency 'opensteam_category'

Opensteam::Extension.register "Opensteam Categories" do
  
  # describe you plugin/extension
  description "categorize products"

  # include Module into ActionView::Base
  helper_modules CategoryHelper

  # inject this dependency into the product class (used for deleveopment environment, since rails reloads our models on
  # every request )
  product_inject_dependency "OpensteamCategory"
  
  # mark this plugin as a product extension (sets routes, display links in admin backend, etc)
  product_extension :categories
  
end
