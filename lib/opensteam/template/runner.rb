#	openSteam - http://www.opensteam.net
#  Copyright (C) 2009  DiamondDogs Webconsulting
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

require 'opensteam/version'
require 'find'
  
module Opensteam
  module Template
  
    # Methods for application-template mechanism of rails 2.3
    class Runner
      
      class << self ;
        # return application_directory for the opensteam templates
        def application_directory
          File.join( File.dirname(__FILE__), "..", "..", "..", "application_templates" )
        end
        
        # returns the path of the opensteams engines (orders, shipments, invoices)
        def engines_path engine = nil
          p = File.join( application_directory, "engines" )
          return p unless engine
          File.join( p, "opensteam_#{engine}")
        end
        
        # returns the path of the core application templates
        def core_application_path
          File.join( application_directory, "core")
        end
        
        # returns the path of the inventory templates
        def inventory_catalog_path
          File.join( application_directory, "catalog/_inventory")
        end
        
        # returns the path of the product templates
        def product_catalog_path
          File.join( application_directory, "catalog/_product")
        end
        
        # returns the path of the property templates
        def property_catalog_path
          File.join( application_directory, "catalog/_property")
        end
        
        
        def authentication_path( what = :authlogic ) #:nodoc:
          File.join( application_directory, "authentication", what.to_s )
        end
        
        # returns the path of the frontend templates
        def frontend_application_path
          File.join( application_directory, "frontend" )
        end
        
        
        def order_sales_path #:nodoc
          File.join( application_directory, 'sales/_order' )
        end

        def invoice_sales_path #:nodoc
          File.join( application_directory, 'sales/_invoice' )
        end

        def shipment_sales_path #:nodoc
          File.join( application_directory, 'sales/_shipment' )
        end

      end
      
      
      
      
      attr_accessor :rails_template_runner
      attr_accessor :user_model
      attr_accessor :frontend_url
      
      # initialize an opensteam template runner
      def initialize( rtr )
        @rails_template_runner = rtr
        r.log "opensteam", Opensteam::VERSION::STRING
      end

      alias :r :rails_template_runner
      
      # delegate all missing methods to the rails application runner
      def method_missing( method_name, *args, &block )
        if r.respond_to?( method_name )
          r.__send__( method_name, *args, &block )
        else
          super
        end
      end
      
      
      # write an opensteam initializer to the generated rails application
      def write_opensteam_initializer
        initializer "opensteam_initializer.rb" do
          "Opensteam::Initializer.run do |config|
             config.user_model = '#{self.user_model}'
           end"
        end
      end
      

      def authentication user_model_name #:nodoc:
        self.user_model = user_model_name.to_s.classify
        user_model_file = self.user_model.to_s.underscore
        sentinel = "class #{self.user_model} < ActiveRecord::Base"
        r.in_root do
          r.gsub_file "app/models/#{user_model_file}.rb", /(#{Regexp.escape(sentinel)})/mi do |match|
            "#{match}\n  include Opensteam::User::UserLogic\n"
          end
        end
      end
      
      # generate the frontend files
      def frontend args = {}
        Find.find( self.class.frontend_application_path ) do |f|
          file = f.split("application_templates/frontend/").last
          r.file( file, File.open(f,'rb'){|f| f.read} ) unless File.directory?( f )
        end
        
        self.frontend_url = args[:url] if args[:url]
        
        
        frontend_routes = <<FRONTEND_ROUTES

        # shop alias
        # map.#{self.frontend_url} "#{self.frontend_url}", :controller => "opensteam", :action => 'index'
        map.shop_index "shop", :controller => "products", :action => 'index'
        map.store_index "store", :controller => "opensteam", :action => 'index'
        map.opensteam_index "opensteam", :controller => "opensteam", :action => 'index'
        # map.resources :#{self.frontend_url}, :controller => "products"

        map.resources :webshop, :controller => "products"
        map.resources :searches
        map.resource :cart
        map.resources :products, :member => { :inventory => :any }, :collection => { :checkout => :post }
        map.start_checkout "products/checkout", :controller => "products"
FRONTEND_ROUTES

        add_routes( frontend_routes )
        
        
      end
      
      # generate the catalog files (product, properties, inventories)
      # if no block is given, all files are created
      #
      #   catalog do
      #     product
      #     properties
      #     inventories
      #   end
      def catalog process = :full, &block
        c = Catalog.new( r )
        if block_given?
          c.instance_eval( &block )
        else
          c.product :base => "Product"
          c.property :base => "Property"
          c.inventory :base => "Inventory"
        end
      end
      
      # generate the sales files (order, shipments and invoices)
      # if no block is given, all files are created
      #
      # order, shipment and invoices are rails engines, and are generated into vendor/plugins
      def sales process = :full, &block
        s = Sales.new( r )
        if block_given?
          s.instance_eval( &block )
        else
          s.order
          s.invoice
          s.shipment
        end
      end
      
      
      # generate the config files (shipping_rates)
      # if no block is given, all files are created
      # 
      # the 'shipping_rate' calculation functionality lies in a rails engine.
      def config process = :full, &block
        c = Config.new( r )
        if block_given?
          c.instance_eval( &block )
        else
          c.shipping_rates
        end
      end
      
      
      
      # add opensteam specific routes to the generate rails application
      def add_routes(routing_code)
        log 'opensteam', 'routes'
        sentinel = 'ActionController::Routing::Routes.draw do |map|'

        r.in_root do
          r.gsub_file 'config/routes.rb', /(#{Regexp.escape(sentinel)})/mi do |match|
            "#{match}\n  #{routing_code}\n"
          end
        end
      end


      # generate the opensteam core files (admin-backend)
      def core file_name, args = {}
        
        Find.find( self.class.core_application_path ) do |f|
          file = f.split("application_templates/core/").last
          r.file( file, File.open(f,'rb'){|f| f.read} ) unless File.directory?( f )
        end
        
        
        administration_routes = <<END_OPENSTEAM_ROUTES

    ## users / sessions (login/logout/register/signup)
    #map.logout '/logout', :controller => 'sessions', :action => 'destroy'
    #map.login '/login', :controller => 'sessions', :action => 'new'
    #map.register '/register', :controller => 'accounts', :action => 'create'
    #map.signup '/signup', :controller => 'accounts', :action => 'new'
    #map.activate '/activate/:activation_code', :controller => 'accounts', :action => 'activate'
    #map.resource :session
    
    map.resource :account, :member => {
      :edit_password => :get,
      :update_password => :put,
      :activate => :get
    }


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
        
        
        add_routes( administration_routes )
        r.gem 'opensteam'
        self.authentication args[:user] if args[:user]

      end
    end
    
    class Base #:nodoc:
      attr_accessor :rails_template_runner
      
      def initialize( rtr )
        @rails_template_runner = rtr
      end
      
      
      def method_missing(method_name, *args, &block)
        if r.respond_to?( method_name )
          r.__send__( method_name, *args, &block )
        else
          super
        end
      end
      
      alias :r :rails_template_runner
    end
    
    class Sales < Base #:nodoc:
      
      # install opensteam_order plugin from github
      def order args = {}
        r.plugin 'opensteam_orders', 
          :git => 'git://github.com/opensteam/opensteam_orders.git'
      end
      
      # install opensteam_invoice plugin from github
      def invoice args = {}
        r.plugin 'opensteam_invoice',
          :git => 'git://github.com/opensteam/opensteam_invoice.git'
          
        r.rake 'opensteam:plugins:invoice:install'
      end
      
      
      # install opensteam_shipment plugin from github
      def shipment args = {}
        r.plugin 'opensteam_shipment',
          :git => 'git://github.com/opensteam/opensteam_shipment.git'
          
        r.rake 'opensteam:plugins:shipment:install'
      end
      
    end
    
    class Config < Base #:nodoc:
      
      # install opensteam_shipping_rate plugin from github
      def shipping_rates
        r.plugin 'opensteam_shipping_rate',
          :git => 'git://github.com/opensteam/opensteam_shipping_rate.git'
        
        rake 'opensteam:plugins:shipping_rate:install'
      end
    end
    
    
    class Catalog < Base #:nodoc:
      
      def product args = {}
        Find.find( Opensteam::Template::Runner.product_catalog_path ) do |f|
          ff = f.split("catalog/_product").last
          r.file( ff, File.read( f ) ) unless File.directory?( f )
        end
      end
      
      def property args = {}
        Find.find( Opensteam::Template::Runner.property_catalog_path ) do |f|
          ff = f.split("catalog/_property").last
          r.file( ff, File.read( f ) ) unless File.directory?( f )
        end
      end
      
      def inventory args = {}
        Find.find( Opensteam::Template::Runner.inventory_catalog_path ) do |f|
          ff = f.split("catalog/_inventory").last
          r.file( ff, File.read( f ) ) unless File.directory?( f )
        end
      end
      
      private

      
    
    end
    
    
  end
end
