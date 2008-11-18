## INIT opensteam_categories PLUGIN

require 'opensteam'

# include controller (LOAD_PATH, Dependencies and config)
controller_path = File.join( File.dirname(__FILE__), 'controller' )
$LOAD_PATH << controller_path
ActiveSupport::Dependencies.load_paths << controller_path
config.controller_paths << controller_path


#include views
ActionController::Base.append_view_path File.join( File.dirname(__FILE__), "views" )

require File.join( File.dirname(__FILE__), 'lib', 'categories_inventory' )
require File.join( File.dirname(__FILE__), 'lib', 'category' )



