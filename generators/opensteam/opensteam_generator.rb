#	openSteam - http://www.opensteam.net
#  Copyright (C) 2008  DiamondDogs Webconsulting
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; version 2 of the License.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License along
#  with this program; if not, write to the Free Software Foundation, Inc.,
#  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

class OpensteamGenerator < Rails::Generator::NamedBase

		
  attr_reader	:controller_class_name, :controller_file_name

							
  def initialize(runtime_args, runtime_options = {})
    super
				
    @controller_class_name = class_name + "Controller"
    @controller_file_name  = file_name + "_controller.rb"
	
  end

  require 'find'
  require 'yaml'

  def ffind_in_file(file,*strs)
   # file = File.join( File.dirname( __FILE__), "templates", file )
   # puts "'#{file}'"
    if File.file?( file )
      strs.each { |str| File.open(file).grep(/#{str}/) { |line| return :template  } }
      return :file
    end
    return :directory
  end

  
  def manifest
    record do |m|

      m.class_collisions class_path, class_name, "#{class_name}Test"
      m.class_collisions class_path, "#{controller_class_name}"

      Dir.chdir( File.dirname(__FILE__) )
      Find.find("./templates/"  ) do |f|
        ret = ffind_in_file(f, "<%%", "## TEMPLATE ##" )
        next if f.include?( '.svn' )
        f = f.gsub(/^\.\/templates\//,'')
        if f.include?( 'vendor' )
          ret == :directory ? m.send( ret, f ) : m.send( :file, f, f )
        else
          ret == :directory ? m.send( ret, f =~ /webshop/ ? f.gsub(/webshop/,"#{file_name}") : f ) : m.send(ret,f , f =~ /webshop/ ? f.gsub(/webshop/,"#{file_name}") : f, :collision => :force )
        end
      end

      administration_routes = <<END_OPENSTEAM_ROUTES
	  
  ## users / sessions (login/logout/register/signup)
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'accounts', :action => 'create'
  map.signup '/signup', :controller => 'accounts', :action => 'new'
  map.activate '/activate/:activation_code', :controller => 'accounts', :action => 'activate'
  map.resource :session
  map.resource :account, :member => {
    :edit_password => :get,
    :update_password => :put,
    :activate => :get
  }
  
  #### WEBSHOP ####
  
  map.resources :searches
  map.resource  :cart
  map.resources :products, :member => { :inventory => :any }, :collection => { :checkout => :post }
  
  map.cart "/cart/*quantity", :controller => 'cart', :action => 'update', :conditions => { :method => :post }
  map.start_checkout "products/checkout", :controller => "products"
  
  # shop alias
  map.#{file_name} "#{file_name}", :controller => "opensteam", :action => 'index'
  map.shop_index "shop", :controller => "products", :action => 'index'
  map.store_index "store", :controller => "opensteam", :action => 'index'
  map.opensteam_index "opensteam", :controller => "opensteam", :action => 'index'
  map.resources :#{file_name}, :controller => "products"
  
  # admin top level
  map.administration "admin", :controller => 'admin', :action => 'index'
  
  map.admin_payment_types "/admin/payment_types", :controller => "admin", :action => "payment_types"
  map.toggle_admin_payment_type "/admin/toggle_payment_type/:id", :controller => "admin", :action => "toggle_payment_type"
  map.comming_soon "/admin/comming_soon", :controller => 'admin', :action => 'comming_soon'


  ## namespaces

  # /admin
  map.admin "admin", :controller => 'admin', :action => 'index'
  map.add_property_group "admin/add_property_group_path/:product_id", :controller => 'admin', :action => 'add_property_group'
  map.namespace :admin do |admin|

    # /admin/catalog
    admin.namespace :catalog do |catalog|
      catalog.resources :products do |product|
        product.resources :inventories
        product.resources :properties, :collection => { :index_products => :get }
        product.resources :property_groups
        Opensteam::Extension.product_extensions.each do |ext|
          product.resources ext #, :requirements => { :product_type => "product", :product_id => :id }
        end
      end

      catalog.resources :properties, :collection => { :index_products => :get }

      catalog.resources :property_groups do |property_groups|
        property_groups.resources :properties, :collection => { :index_property_groups => :get }
      end
      
      catalog.resources :inventories do |inventory|
        inventory.resources :properties
      end
      catalog.resources :categories

    end

    # /admin/sales
    admin.namespace :sales do |sales|
      sales.resources :orders, :has_many => [ :shipments, :invoices ]
      sales.resources :shipments
      sales.resources :invoices
    end

    # /admin/config
    admin.namespace :config do |config|
      config.resources :customers, :has_many => [ :orders ]
      config.resources :tax_zones
      config.resources :tax_groups
      config.resources :shipping_rate_groups

      [ :tax_zone, :tax_groups ].each do |c|
        config.connect c.to_s + "/filter", :controller => c.to_s, :action => 'filter', :conditions => { :method => :post }
      end

    end

    # /admin/system
    admin.namespace :system do |system|
      system.resources :users, :member => { :send_event => :put }
      system.resources :user_roles
      system.resources :mailers
      system.resources :configurations
      system.resources :quicksteams, :collection => { :order => :post }
    end

    admin.payment_types "payment_types", :controller => "admin", :action => 'payment_types'

  end


END_OPENSTEAM_ROUTES


      map_namespaceroutes( administration_routes )

      
      ### Patch application.rb ###
      sentinel = 'class ApplicationController < ActionController::Base'
      app_contr = 'app/controllers/application.rb'
      app_contr = Rails::VERSION::STRING > "2.2.2" ? 'app/controllers/application_controller.rb' : app_contr
      incl = <<END_APP_CONTR

  layout '#{file_name}'

  public :render_to_string
  include AuthenticatedSystem
  include RoleRequirementSystem

END_APP_CONTR

      gsub_file app_contr, /(#{Regexp.escape(sentinel)})/mi do |match|
        "#{match}\n  #{incl}"
      end
			
      
      ### Patch environment.rb ###
      sentinel = 'Rails::Initializer.run do |config|'
      incl = <<END_INIT
  config.after_initialize do
    ActiveMerchant::Billing::Base.mode = :test
  end
END_INIT

      gsub_file 'config/environment.rb', /(#{Regexp.escape(sentinel)})/mi do |match|
        "#{match}\n\n#{incl}\n\n"
      end

    end
  end
	
  protected
	
  def gsub_file(relative_destination, regexp, *args, &block)
    path = destination_path(relative_destination)
    content = File.read(path).gsub(regexp, *args, &block)
    File.open(path, 'wb') { |file| file.write(content) }
  end
		
		
  def map_namespaceroutes(str)
    ##
    ## just prints the str to routes.rb
    ## ToDo: implement actual namespace-method, like map_namspaceroutes( :space1 => { :space2 => "resourceA" } )
    ##
    logger.route str
    sentinel = 'ActionController::Routing::Routes.draw do |map|'
			
    unless options[:pretend]
      gsub_file 'config/routes.rb', /(#{Regexp.escape(sentinel)})/mi do |match|
        "#{match}\n  #{str}"
      end
    end
  end
	
	
  # Override with your own usage banner.
  def banner
    "Usage: #{$0} opensteam ShopName"
  end

  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on("--skip-timestamps",
      "Don't add timestamps to the migration files") { |v| options[:skip_timestamps] = v }
    opt.on("--skip-migration",
      "Don't generate a migration files") { |v| options[:skip_migration] = v }
  end

  def scaffold_views
    %w[ index show new edit ]
  end

  def model_name
    class_name.demodulize
  end
end
