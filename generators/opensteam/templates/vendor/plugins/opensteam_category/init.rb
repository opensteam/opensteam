## INIT opensteam_categories PLUGIN

require 'opensteam'
# 
# # include controller (LOAD_PATH, Dependencies and config)
# controller_path = File.join( File.dirname(__FILE__), 'controller' )
# $LOAD_PATH << controller_path
# ActiveSupport::Dependencies.load_paths << controller_path
# config.controller_paths << controller_path
# 
# 
# #include views
# ActionController::Base.append_view_path File.join( File.dirname(__FILE__), "views" )

require_dependency 'opensteam_category'

Opensteam::Extension.register "Opensteam Categories" do
  
  # describe you plugin/extension
  description "categorize products"
  
  # specify the view path for the plugin 
  view_path File.join( File.dirname(__FILE__), "views" )
  
  # specify the controller path for the plugin
  controller_path File.join( File.dirname(__FILE__), "controller" )
  
  # custom routes for you plugin
  plugin_routes do |map|
    map.namespace :admin do |admin|
      map.namespace :catalog do |catalog|
        map.resource :categories
      end
    end
  end
  
  
  # inject this dependency into the product class (used for deleveopment environment, since rails reloads our models on
  # every request )
  product_inject_dependency OpensteamCategory
  
  # mark this plugin as a product extension (sets routes, display links in admin backend, etc)
  product_extension :categories
  
  
  
end
