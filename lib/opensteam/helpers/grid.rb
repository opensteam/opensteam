module Opensteam
  module Helpers




    module Grid




      def self.included(base) #:nodoc:
        base.send( :extend,  ClassMethods )
        #    base.send( :include, InstanceMethods )
      end


      def self.filter_operators #:nodoc:
        ["LIKE", ">", "<", "!=", "<=", ">=", "=", "BETWEEN", "IN" ]
      end

      def self.build_filter_sql tname, tvalue, op
        raise "Operator '#{op}' not allowed in filter!" unless Opensteam::Helpers::Grid.filter_operators.include?( op )
        "\"#{tname}\".\"#{tvalue}\" #{op} :#{tname}_#{tvalue}"
      end

      def self.build_filter_val table_name, keys, val, op
        Array(keys).inject({}) { |r,v| r[ :"#{table_name}_#{v}" ] = ( op == "LIKE" ? "%#{val}%" : ( val.is_a?( Array) ? "(#{val.join(',')})" : val ) ) ; r }
      end

        

      def self.order_direction(dir) #:nodoc:
        
        raise "direction no valid" unless ["ASC", "DESC", "asc", "desc"].include?( dir )
        dir
      end

      module InstanceMethods
        
      end

      class FilterEntry < ActiveRecord::Base
        validates_inclusion_of :op, :in => Opensteam::Helpers::Grid.filter_operators

        def conditions( model )
          model.filter_conditions( self )
        end

      end
      
      module ClassMethods


        def filter filters
          Array(filters).inject(self) { |r,v| r.send( :"filter_#{v.key}", v.op, v.val ) }
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
          self.send( :filter_named_scopes, self.configured_grid )

          self.class_eval do 
            named_scope :order_by, lambda { |column, *dir|
              { :order => Array( self.grid_column_to_sql( column || :id ) ).collect { |s| "#{s} #{Opensteam::Helpers::Grid.order_direction(dir.first) || 'asc'}" }.join(","),
                :include => self.grid_column_includes( column || :id )
              }
            }
          end

          

        end



        # created for every configured_grid entry a named scope for filtering and ordering
        # depending on the configured_grid hash the sql-query is built.
        #
        #   Modelconfigure_grid(
        #     :scope_id => { :association_name => :column_name }
        #   )
        #
        #   Model.configure_grid(
        #     :id => :id,
        #     :customer => { :customer => :email },
        #     :shipping_address => { :shipping_address => [ :street, :city ] )
        #
        #
        #
        # NamedScopes:
        #   Model.filter_id
        #   Model.filter_customer
        #   Model.filter_shipping_addres
        #   Model.order_by_id
        #   Model.order_by_customer
        #   Model.order_by_shipping_address
        #
        # Depending on the parameters for the filter-scopes the sql_query is built:
        #   Model.filter_id( "=", 1 ) # => :conditions => { :id => 1 }
        #   Model.filter_id( ">", 1 ) # => :conditions => [ "'id' > :id", { :id => 1 } ]
        #   Model.filter_customer("LIKE", "booh") # => :conditions => [ "customers.email LIKE :customers_email", { :customers_email => "%buh%" } ]
        #   Model.filter_shipping_address("LIKE", "booh" )
        #   # => :conditions => [ "addresses.street LIKE :addresses_street OR addresses.city LIKE :addresses_city",
        #          { :addresses_city => "%booh%", :addresses_street => "%booh%" }
        #
        # If the association_name (in configure_grid() ) doesnt match the association-table_name, refelct_on_assocation( association_name ) is
        # used to determine the table_name.
        #
        def filter_named_scopes( h = {}, table_name = self.table_name, incl = false, scope_id = nil ) #:nodoc:
          includes = incl ? h.keys.collect(&:to_sym) : []

          h.each_pair do |id, fconfig|
            case fconfig
            when Symbol
              self.class_eval do
                named_scope :"order_by_#{scope_id || id }", lambda { |dir|
                  { :order => "\"#{table_name}\".\"#{fconfig.to_s}\" #{Opensteam::Helpers::Grid.order_direction(dir)}",
                    :include => includes 
                  }
                }
                
                named_scope :"filter_#{scope_id || id}", lambda { |filter_operator, filter_value|
                  { :conditions =>
                      if filter_value.is_a?( Array ) || filter_value.is_a?( Range )
                      { :"#{table_name}.#{fconfig.to_s}" => filter_value }
                    else
                      [ Opensteam::Helpers::Grid.build_filter_sql( table_name, fconfig.to_s, filter_operator ),
                        Opensteam::Helpers::Grid.build_filter_val( table_name, fconfig, filter_value, filter_operator ) ]
                    end,
                    :include => includes
                  }
                }
              end

            when Hash
              self.filter_named_scopes( fconfig, self.reflect_on_association( fconfig.keys.first.to_sym ).table_name, true, scope_id || id )

            when Array
              self.class_eval do
                named_scope :"order_by_#{scope_id || id}", lambda { |dir|
                  { :order => fconfig.collect { |s| "\"#{table_name}\".\"#{s}\" #{Opensteam::Helpers::Grid.order_direction(dir)}" }.join(","),
                    :include => includes
                  }
                }
                
                named_scope :"filter_#{scope_id || id}", lambda { |filter_operator, filter_value|
                  { :conditions => [
                      fconfig.collect { |s| Opensteam::Helpers::Grid.build_filter_sql( table_name, s, filter_operator ) }.join( " OR " ),
                      Opensteam::Helpers::Grid.build_filter_val(table_name, fconfig, filter_value, filter_operator )
                    ],
                    :include => includes
                  }
                }
              end

            end

          end
        end




       
        def grid_column( id = :id ) #:nodoc:
          puts "-------------------------------------------------"
          puts id
          self.configured_grid[ id.to_sym ]
        end

        def grid_column_to_sql( id = :id ) #:nodoc:
          if( gc = grid_column( id ) ).is_a?( Symbol )
            return "\"#{self.table_name}\".\"#{gc}\""
          else
            if gc.values.first.is_a?( Array )
              gc.values.first.collect { |s| "\"#{self.reflect_on_association(gc.keys.first.to_sym).table_name}\".\"#{s}\"" }
            else
              return "\"#{self.reflect_on_association(gc.keys.first.to_sym).table_name}\".\"#{gc.values.first}\""
            end
          end
        end

        def grid_column_includes( id = :id ) #:nodoc:
          grid_column( id ).is_a?( Symbol ) ? [] : [ id ] ;
        end


        # returns the +configured_grid+.+keys+
        def filtered_keys
          self.configured_grid.keys.collect(&:to_s)
        end

        # returns the :condition hash for given filter-entry objects
        def filter_conditions filter
          Array(filter).inject({}) { |r,v|
            r.merge( self.parse_filter_params( :op => v.op, :key => v.key, :val => v.val ) )
          }
        end


      end



    end
  end
end