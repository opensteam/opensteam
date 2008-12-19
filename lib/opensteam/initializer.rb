module Opensteam

  class << self ;

    def configuration
      @@configuration
    end
    
    def log_level
      @@log_level
    end


    def configuration=(configuration)
      @@configuration = configuration
    end

    def log_level=(lv)
      @@log_level = lv
    end

    def _log(args)
      logger = ( defined? RAILS_DEFAULT_LOGGER ) ? RAILS_DEFAULT_LOGGER : Logger.new("#{RAILS_ROOT}/log/#{RAILS_ENV}.log")
      logger.send( self.log_level, "** [openSteam] #{args}" )
    end
  end


  class Configuration < Rails::Configuration

    attr_accessor :opensteam_init_libs
    attr_accessor :payment_paths
    attr_accessor :opensteam_product_extensions
    attr_accessor :opensteam_active_record_extensions
    attr_accessor :opensteam_extension_loader
    attr_accessor :opensteam_model_paths
    attr_accessor :opensteam_mailer_paths


    def initialize
      Opensteam.log_level = :info
      super
      Opensteam._log "initialize openSteam Configuration"

      self.opensteam_init_libs = default_init_libs
      require self.opensteam_init_libs
      self.payment_paths = default_payment_paths
      self.opensteam_active_record_extensions = [ Opensteam::Base::Extension ]
      self.opensteam_product_extensions = []

      self.opensteam_extension_loader = Opensteam::Extension
      self.opensteam_model_paths = default_opensteam_model_paths
      self.opensteam_mailer_paths = default_opensteam_mailer_paths

    end

    private
    
    def default_init_libs
      "opensteam/init_libs"
    end

    def default_payment_paths
      [ File.join( File.dirname(__FILE__), "payment" ) ]
    end

    def default_opensteam_model_paths
      [ File.join( RAILS_ROOT, "app", "models" ) ]
    end

    def default_opensteam_mailer_paths
      [ File.join( "#{RAILS_ROOT}", "app", "models", "mailer" ) ]
    end



  end


  class Initializer < Rails::Initializer

    def self.run( command = :process, configuration = Configuration.new )
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
      super
      extend_active_record
      initialize_opensteam_extensions
      initialize_opensteam_models
      initialize_inventory_property_accessors
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
      require File.join( File.dirname(__FILE__), "helpers", "extend_stuff.rb" )
    end

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