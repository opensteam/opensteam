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
  module Helpers



    # grid functionality for opensteam models (product, properties, orders, shipments, etc )
    # mainly used for ExtJS Grid integration
    module Grid

      def self.included(base) #:nodoc:
        base.send( :extend,  ClassMethods )
        base.send( :include, InstanceMethods )


        base.class_eval do
          named_scope :filter_scope, lambda { |keys, operator, value|
            Opensteam::Helpers::Filter.filter_scope( self, self.grid_column(keys), operator, value )
          }

          named_scope :order_by, lambda { |key, *dir|
            Opensteam::Helpers::Filter.orderby_hash( self, self.grid_column(key), dir.first )
          }

          class_inheritable_accessor :conf_grid
        end



      end

      # Filter Entry Model
      class FilterEntry < ActiveRecord::Base
        validates_inclusion_of :op, :in => Opensteam::Helpers::Filter.check_operator
      end


      # some instance methods for xml generation for ExtJS Grid
      module InstanceMethods

        def editor_url ; "#{self.class.to_s.demodulize.underscore.singularize}/#{self.id}" ; end

        def configured_grid_value object, method
          return nil if object.nil?

          case method
          when Hash
            self.configured_grid_value( object.send( method.keys.first ), *method.values )
          else
            if method == :count
              object.send( :size )
            else
              if object.is_a?( Array )
                Array(object).collect { |o| Array(method).collect { |m| o.send( m ) }.join(", ") }.join(",") ;
              else
                Array(method).collect { |m| object.send( m ) }.join(", ")
              end
              #              Array(object).collect { |s| Array(method).collect { |m| s.send( m ) }.join(",") }.join(",")
            end
          end
        end

        def to_ext_xml options = {}
          options[:indent] ||= 2
          options[:builder] || Builder::XmlMarkup.new( :indent => options[:indent] )
          options[:root] = "Item"
          options[:skip_instruct] = true
          options[:dasherize] = false

          self.class.configured_grid.inject({}) { |r,v|
            r[ v.first ] = self.configured_grid_value( self, v.last ) ; r
          }.to_xml( options )

        end


      end


      module ClassMethods

        def filter filters
          Array(filters).inject(self) { |r,v|
            r.send( :filter_scope, v.key, v.op, v.val )
          }
        end



        # configure a grid for the admin backend
        #
        #   Model.configure_grid(
        #     :id => :id,
        #     :customer => { :customer => :email },
        #     :address => { :address => [ :firstname, :lastname, :street, :city ] }
        #     ... )
        #
        def configure_grid( opts )
          self.conf_grid = opts
        end

        # returns the configured grid hash
        def configured_grid
          self.conf_grid || self.superclass.conf_grid
        end

        # get the value of the configured_grid hash
        def grid_column( id = :id ) #:nodoc:
          self.configured_grid[ id.to_sym ] || id
        end

        # returns the +configured_grid+.+keys+
        def filtered_keys
          self.configured_grid.keys.collect(&:to_s)
        end

      end



    end
  end
end