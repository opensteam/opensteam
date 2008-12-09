module Opensteam
  module Helpers




    module Grid

      
      def self.included(base) #:nodoc:
        base.send( :extend,  ClassMethods )
        base.send( :include, InstanceMethods )


        base.class_eval do
          named_scope :filter_scope, lambda { |keys, operator, value|
            Opensteam::Helpers::Filter.filter_scope( self, keys, operator, value )
          }

          named_scope :order_by, lambda { |key, *dir|
            Opensteam::Helpers::Filter.orderby_hash( self, key, dir.first )
          }

        end



      end


      class FilterEntry < ActiveRecord::Base
        validates_inclusion_of :op, :in => Opensteam::Helpers::Filter.check_operator
      end


      module InstanceMethods
        

        def configured_grid_value object, method
          case method
          when Hash
            self.configured_grid_value( object.send( method.keys.first ), *method.values )
          else
            if method == :count
              object.send( :size )
            else
              Array(object).collect { |s| Array(method).collect { |m| s.send( m ) }.join(",") }.join(",")
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
          @configured_grid = opts
          class << self ; attr_accessor :configured_grid ; end
        end

        def grid_column( id = :id ) #:nodoc:
          self.configured_grid[ id.to_sym ]
        end

        # returns the +configured_grid+.+keys+
        def filtered_keys
          self.configured_grid.keys.collect(&:to_s)
        end

      end



    end
  end
end