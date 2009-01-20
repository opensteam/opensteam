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

  module Extension

    mattr_accessor :plugins
    self.plugins = []

    mattr_accessor :product_extensions
    self.product_extensions = []

    mattr_accessor :product_dependency
    self.product_dependency = []

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

          # inject product dependency modules
          ActiveSupport::Dependencies.inject_dependency ::Product, *self.product_dependency.flatten

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

      
      def product_inject_dependency *mod
        Opensteam::Extension.product_dependency << mod
#        ActiveSupport::Dependencies.inject_dependency Product, *mod
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