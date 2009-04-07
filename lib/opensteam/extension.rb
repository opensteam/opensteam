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

  # module to handle and register Opensteam Extensions
  module Extension

    mattr_accessor :plugins

    mattr_accessor :product_extensions
    self.product_extensions = []
    
    mattr_accessor :extensions

    mattr_accessor :product_dependency_array
    
    

    class << self ;
      
      def extensions_for( sym ) #:nodoc:
        self.extensions[ sym.to_sym ]
      end
      
      # return extensions for backend +namespace+
      def extensions_for_backend( namespace )
        ( self.plugins  || [] ).select { |s| s.information[:backend] == namespace }
      end
      
      
      def product_dependency #:nodoc:
        self.product_dependency_array ||= []
      end

      # register an opensteam extension
      def register *name, &block
        self.extensions ||= {}
        self.plugins ||= []
        plugin = Base.new
        if name.first.is_a?( Hash )
          plugin.id = name.first.values.first
          self.extensions[ name.first.keys.first.to_sym ] ||= []
          self.extensions[ name.first.keys.first.to_sym ] << plugin
        elsif name.first.is_a?( Symbol )
          plugin.id = name.first
        end
        plugin.instance_eval(&block)
        self.plugins << plugin
      end

      # initialize all opensteam extensions
      def initialize_extensions(config)
        #self.plugins.each do |plugin|

          ##########
          # NO LONGER NEEDER, due to Rails 2.3 ENGINES SUPPORT
          ##
          ## # add controller_paths
          # $LOAD_PATH << plugin.controller_path
          # ActiveSupport::Dependencies.load_paths << plugin.controller_path
          # config.controller_paths << plugin.controller_path

          # add view_paths
          # ActionController::Base.append_view_path plugin.view_path
          ##############
          
          
          # inject product dependency modules
          ActiveSupport::Dependencies.inject_dependency ::Product, *self.product_dependency.flatten
          self.product_dependency.flatten.each { |mod| mod.constantize }
        #end
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

      attr_accessor :information, :name, :id
      dsl_accessor  :description, :view_path, :controller_path, :backend


      def initialize( name = "" ) #:nodoc:
        @name = name
        @information = {}
      end

      # register module as a product dependency (gets reloaded when the product model does)
      def product_inject_dependency *mod
        Opensteam::Extension.product_dependency << mod
        #        ActiveSupport::Dependencies.inject_dependency Product, *mod
      end

      
      # set routes in plugins
      # NOT NEEDED due to Rails 2.3 Engine support
      def plugin_routes &block
        return self.information[:plugin_routes] unless block_given?
        self.information[:plugin_routes] = block
      end

      # mark extension as a product extension (set links in admin backend, like 'categories', 'tags', etc)
      def product_extension t
        Opensteam::Extension.product_extensions << t
      end

      # mark module as view helper
      # NOT NEEDED due to RAils 2.3 Engine support
      def helper_modules *mod
        mod.each do |m|
          ActionView::Base.send :include, m
        end
      end

    end
  


    # extend ActionController Routing to load plugin-routes
    # NOT NEEDED due to Rails 2.3 Engine support
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

end