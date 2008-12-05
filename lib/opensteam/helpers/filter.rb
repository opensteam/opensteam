module Opensteam::Helpers

  module Filter



    class << self ;



      def order_named_scope( model )
        model.class_eval do
          named_scope :order_by, lambda { |id, *dir|
            order = Opensteam::Helpers::Filter.order_direction( dir.first)
            { :order => Opensteam::Helpers::Filter.grid_column_sql( self, self.grid_column( id ) ).collect { |s| "#{s} #{order}" }.join(","),
              :include => Opensteam::Helpers::Filter.order_include( self, id )
            }
          }
        end
      end


      def order_include model, id #:nodoc:
        model.reflect_on_association( id.to_sym ) ? [ id.to_sym ] : [ ]
      end
      
      def grid_column_sql( model, hconfig, opts = {} ) #:nodoc:
        table_name = opts[:table_name] || model.table_name

        case hconfig
        when Hash
          Opensteam::Helpers::Filter.grid_column_sql( model, hconfig.values.first, :table_name => model.reflect_on_association( hconfig.keys.first ).table_name )
        else
          Array(hconfig).collect { |s| "\"#{table_name}\".\"#{s}\"" }
        end
      end


      def order_direction( dir ) #:nodoc:
        dir ||= 'asc'
        if ["asc", "desc", "ASC", "DESC"].include?( dir )
          dir
        else
          raise ArgumentError, "order direction #{dir} not allowed!"
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
      def filter_named_scopes( model, hconfig, opts = {} )
        includes = opts[:include] ? hconfig.keys.collect(&:to_sym) : []
        table_name = opts[:table_name] || model.table_name


        hconfig.each_pair do |column_id, filter_config|
          scope_id = opts[:scope_id] || column_id
          case filter_config

          when Hash
            self.filter_named_scopes( model, filter_config,
              :table_name => model.reflect_on_association( filter_config.keys.first.to_sym ).table_name,
              :include => true, :scope_id => scope_id )

          else
            model.class_eval do
              named_scope :"filter_#{scope_id}", lambda { |*filter|
                { :conditions => Opensteam::Helpers::Filter.conditions_for( table_name, filter_config, *filter ),
                  :include => includes }
              }
            end

          end


        end

      end


      # checks if given operator is in the list of allowed operators, if not raises an ArgumentError
      def filter_operators( op = nil ) #:nodoc:
        ops = ["LIKE", "=", ">", "<", ">=", "<=", "IN", "BETWEEN", "!=" ]
        return ops unless op
        if ops.include?( op )
          op
        else
          raise ArgumentError, "filter #{op} not allowed!!"
        end
      end

      
      def filter_value( op, v ) #:nodoc:
        op == "LIKE" ? "%#{v}%" : v
      end



      def conditions_for( table_name, columns, *filter ) #:nodoc:
        raise ArgumentError, "2 filter arguments expected" if filter.size > 2 || filter.size == 0
        if filter.first.is_a?( Array ) || filter.first.is_a?( Range )
          { :"#{table_name}" => Array(columns).inject({}) { |r,v| r[ :"#{v}" ] = filter.first ; r } }
        else
          op = self.filter_operators( filter.first )
          [ Array(columns).collect { |c| "\"#{table_name}\".\"#{c}\" #{op} :#{table_name}_#{c}" }.join(" OR "),
            Array(columns).inject({}) { |r,v| r[:"#{table_name}_#{v}" ] = filter_value( filter.first, filter.last ) ; r } ]
        end
      end

    end


  end






end