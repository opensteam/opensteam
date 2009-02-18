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


module Opensteam

  class << self ;

    # holds the opensteam configuration object
    def configuration
      @@configuration
    end
    
    
    def log_level #:nodoc:
      @@log_level
    end


    def configuration=(configuration) #:nodoc:
      @@configuration = configuration
    end

    def log_level=(lv) #:nodoc:
      @@log_level = lv
    end

    def _log(args)
      logger = ( defined? RAILS_DEFAULT_LOGGER ) ? RAILS_DEFAULT_LOGGER : Logger.new("#{RAILS_ROOT}/log/#{RAILS_ENV}.log")
      logger.send( self.log_level, "** [openSteam] #{args}" )
    end
  end


  # Configuration Class
  #
  class Configuration < Rails::Configuration

    # file of opensteam libraries to require on startup
    attr_accessor :opensteam_init_libs
    
    # path of payment classes
    attr_accessor :payment_paths
    
    # list of product extension modules
    attr_accessor :opensteam_product_extensions
    
    # list of active_record extension modules
    attr_accessor :opensteam_active_record_extensions

    # opensteam extension loader class
    attr_accessor :opensteam_extension_loader
    
    # paths of opensteam models
    attr_accessor :opensteam_model_paths

    # paths of mailer classes
    attr_accessor :opensteam_mailer_paths
    
    # path of opensteam catalog models (product, properties, inventories)
    attr_accessor :opensteam_catalog_models_path
    
    # main shop controller of opensteam rails-application
    attr_accessor :opensteam_shop_controller


    def initialize #:nodoc:
      Opensteam.log_level = :info
      super
      Opensteam._log "initialize openSteam Configuration"

      self.opensteam_init_libs = default_init_libs
      require self.opensteam_init_libs
      self.payment_paths = default_payment_paths
      self.opensteam_active_record_extensions = [ ]
      self.opensteam_product_extensions = []

      self.opensteam_extension_loader = Opensteam::Extension
      self.opensteam_model_paths = default_opensteam_model_paths
      self.opensteam_mailer_paths = default_opensteam_mailer_paths
      self.opensteam_catalog_models_path = default_opensteam_catalog_models_path
      self.load_paths << self.opensteam_catalog_models_path

    end

    private
    
    # default opensteam libraries
    #   "opensteam/init_libs.rb"
    def default_init_libs
      "opensteam/init_libs"
    end

    # default path of opensteam catalog models
    def default_opensteam_catalog_models_path
      File.join( "#{RAILS_ROOT}", "app", "models", "catalog" )
    end

    # default paths of payment classes
    def default_payment_paths
      [ File.join( File.dirname(__FILE__), "payment" ) ]
    end


    # default paths of opensteam models
    def default_opensteam_model_paths
      return []
      
      [ File.join( RAILS_ROOT, "app", "models" ),
        File.join( RAILS_ROOT, "app", "models", "catalog" )
      ]
    end

    # default paths of opensteam mailer classes
    def default_opensteam_mailer_paths
      [ File.join( "#{RAILS_ROOT}", "app", "models", "mailer" ) ]
    end



  end

  # Opensteam Initializer class
  # Based on Rails::Initializer
  #
  # Use like the regular Rails::Initializer in your environment.rb file
  # Takes the same config arguments as the Rails::Initializer, plus the
  # configuration parameters of the Opensteam::Configuration class.
  #
  #   Opensteam::Initializer.run do |config|
  #   end
  #
  #
  class Initializer < Rails::Initializer

    def self.run( command = :process, configuration = Configuration.new ) #:nodoc:
      Opensteam._log "run openSteam Initializer"
            
      super

      Opensteam.configuration = configuration
      Opensteam._log( "loaded!")
    end


    
    def load_application_initializers
      require_payment_classes
      super
    end

    def after_initialize
      ActionController::Routing::Routes.class_eval do ; send( :include, Opensteam::Extension::Routing ) ; end
      super
      extend_active_record
      initialize_opensteam_extensions
      initialize_opensteam_models
      #initialize_inventory_property_accessors
      initialize_mailer_classes

      register_payment_types
      extend_stuff

    end


    def initialize_inventory_property_accessors
      Opensteam::Models::Inventory.define_property_accessors
    end

    def register_payment_types
      Opensteam::Payment::Types.register_payment_types!if ActiveRecord::Base.connection.table_exists?( Opensteam::Payment::Types.table_name )
    end


    def initialize_opensteam_models
      configuration.opensteam_catalog_models_path.each do |path|
        Dir.glob( File.join( path, "*.rb" ) ).each { |f| require_dependency f }
      end

      configuration.opensteam_model_paths.each do |path|
        Dir.glob( File.join( path, "*.rb" ) ).each { |f| require_dependency f }
      end
    end


    # extend active record with configured modules
    # used to inject the Opensteam::Base::Extension functionality (opensteam macro) into ActiveRecord::Base
    #
    def extend_active_record
      configuration.opensteam_active_record_extensions.each do |ext|
        ActiveRecord::Base.send( :include, ext )
      end
    end

    # extend the opensteam product model
    # inject every module, as configured in +opensteam_product_extensions+, into the Product Model
    def extend_opensteam_product
      configuration.opensteam_product_extensions.each do |ext|
        Opensteam::ProductBase.extend_product ext
      end
    end

    def initialize_opensteam_extensions
      configuration.opensteam_extension_loader.initialize_extensions( configuration)
    end

    def require_payment_classes
      configuration.payment_paths.each do |p|
        Dir.glob( File.join( p, "*.rb" ) ) { |f| require f }
      end
    end


    def extend_stuff
      require File.join( File.dirname(__FILE__), "rails_extensions", "core.rb" )
      #require File.join( File.dirname(__FILE__), "rails_extensions", "dependency_injection.rb" )
    end

    # initialize the mailer classes
    # register every mailer class (in +opensteam_mailer_paths+) into the database.
    def initialize_mailer_classes
      if ActiveRecord::Base.connection.tables.include?( Opensteam::System::Mailer.table_name )
        configuration.opensteam_mailer_paths.each do |path|
          Dir.glob( File.join( path, "*mailer*" ) ).each { |mp|
            file = "Mailer::" + File.basename(mp, '.rb' ).classify
            file.constantize.instance_methods(false).each { |m|
              Opensteam::System::Mailer.find_or_create_by_mailer_class_and_mailer_method( :mailer_class => file, :mailer_method => m, :active => true )
            }
          }
        end
      end
      
    end

  end



end