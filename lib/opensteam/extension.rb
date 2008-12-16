module Opensteam

  module Extension

    mattr_accessor :plugins
    self.plugins = []

    mattr_accessor :product_extensions
    self.product_extensions = []

    class << self ;

      # register an opensteam extension
      def register name, &block
        plugin = Base.new
        plugin.instance_eval(&block)
        self.plugins << plugin
      end

      # initialize all opensteam extensions
      def initialize_extensions(config)
        self.plugins.each do |plugin|
          # add controller_paths
          $LOAD_PATH << plugin.controller_path
          ActiveSupport::Dependencies.load_paths << plugin.controller_path
          config.controller_paths << plugin.controller_path

          # add view_paths
          ActionController::Base.append_view_path plugin.view_path
        end
      end


    end



    class Base

      # define dsl-like accessors
      def self.dsl_accessor(*symbols) #:nodoc:
        symbols.each do |m|
          self.send( :define_method, m ) do |*value|
            return self.information[m] unless value.first
            self.information[m] = value.first
          end
        end
      end

      attr_accessor :information, :name
      dsl_accessor  :description, :view_path, :controller_path


      def initialize( name = "" )
        @name = name
        @information = {}
      end


      def plugin_routes &block
        return self.information[:plugin_routes] unless block_given?
        self.information[:plugin_routes] = block
      end

      def product_extension t
        Opensteam::Extension.product_extensions << t
      end

    end
  end


  # extend ActionController Routing to load plugin-routes
  module Routing #:nodoc:
    def self.included(base) #:nodoc:
      base.class_eval { alias_method_chain :draw, :opensteam_extension_routes }
    end

    def draw_with_opensteam_extension_routes #:nodoc:
      draw_without_opensteam_extension_routes do |map|
        Opensteam::Extension.plugins.each do |plugin|
          plugin.plugin_routes.call( map )
        end
        yield map
      end
    end
  end



end