module Opensteam::Helpers

  module Filter



    class << self ;

      # check if operator is in the list of allowed operators
      # if not, raises an ArgumentError
      # if no operator is given, list of all allowed operators is returned
      def check_operator op = nil #:nodoc:
        operators = ['LIKE', '>', '<', '>=', '<=', '!=', 'IN', 'BETWEEN' ] 
        return operators unless op
        raise ArgumentError, "operator #{op} not allowed!" unless operators.include?( op )
        op
      end

      def convert_value v, o
        o == "LIKE" ? "%#{v}%" : v
      end


      # create a hash (including :conditions, :include, :group, ..) for the
      # filter_scope NamedScope
      #
      # +keys+ can be either a Symbol (for the column), an array (lots of columns),
      # or a Hash (for the associations).
      # The method will try to determine the correct table_name for the association
      # by calling _reflect_on_association_ on the given model.
      #
      # returns a hash with the correct (sanitized) sql conditions, the includes
      # (if associations are used), and a group-string (if count is used)
      #
      def filter_scope( model, keys, operator, value, opts = {} )
        table_name = opts[:table_name] || model.table_name
        include = opts[:include] || []

        return self.filter_scope( model, keys.values.first, operator, value, {
            :table_name => model.reflect_on_association( keys.keys.first ).table_name,
            :include    => keys.keys.collect(&:to_sym)
          }) if keys.is_a?( Hash )

        qtable_name  = ActiveRecord::Base.connection.quote_table_name( table_name )
        qvalue       = Opensteam::Helpers::Filter.convert_value( value, operator )
        qoperator    = Opensteam::Helpers::Filter.check_operator( operator )
          
        if Array(keys).include? :count
          sqtable_name = ActiveRecord::Base.connection.quote_table_name( model.table_name )
          qcolumn_name = ActiveRecord::Base.connection.quote_column_name( 'id' )
          qvalue       = ActiveRecord::Base.connection.quote( qvalue )
        
          conditions = "#{qtable_name}.#{qcolumn_name}"
          group      = "#{sqtable_name}.#{qcolumn_name} HAVING COUNT( #{qtable_name}.#{qcolumn_name} ) #{qoperator} #{qvalue}"
        else
          conditions = [
            Array(keys).collect { |k|
              qk = ActiveRecord::Base.connection.quote_column_name( k )
              "#{qtable_name}.#{qk} #{qoperator} :#{table_name}_#{k}"
            }.join( " OR "),
            
            Array(keys).inject({}) { |r,k|
              r[:"#{table_name}_#{k}"] = qvalue ; r
            }
          ]
        end


        returning({}) do |scope_hash|
          scope_hash[:conditions] = conditions
          scope_hash[:include]    = include
          scope_hash[:group]      = group if group
        end

      end




      # returns an order by hash, used for scopes
      def orderby_hash( model, key, dir = 'ASC', opts = {} )
        table_name = opts[:table_name] || model.table_name
        include = opts[:include] || []
        dir ||= 'asc'
        raise ArgumentError, "Direction'#{dir}' not allowed!" unless ['asc', 'desc'].include?( dir.downcase )

        return orderby_hash( model, key.values.first, dir, {
            :table_name => model.reflect_on_association( key.keys.first ).table_name,
            :include    => key.keys.collect(&:to_sym)
          }) if key.is_a?( Hash )


        qtable_name  = ActiveRecord::Base.connection.quote_table_name( table_name )
        order = Array(key).collect { |k|
          qk = ActiveRecord::Base.connection.quote_column_name( k )
          "#{qtable_name}.#{qk} #{dir}" }.join(",")

        return { :order => order, :include => include }


      end



    end


  end






end