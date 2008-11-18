module Opensteam

  module System



    class FilterEntry < ActiveRecord::Base


      attr_accessor :model

      class << self ;
        # allowed operators for filter
        def allowed_operators
          ['<', '>', '<=', '>=', '!=', '=', 'LIKE' ]
        end
      end


      validates_inclusion_of :op, :in => allowed_operators

      # Filter Methods
      # to be included into modules
      module Filter

        def self.included( base ) #:nodoc:
          base.extend( ClassMethods )
        end

        module ClassMethods

          # configure filter for model
          # *opts* => Hash
          # used to define association columns for filter (if column can't be identified by reflect_on_association, or multiple columns are used)
          #   Order.configure_filter( :customer => "users.email" )
          #   Order.configure_filter( :customer => ["users.firstname", "user.lastname" ] )
          #
          def configure_filter( opts )
            @configured_filter = opts
            class << self ; attr_accessor :configured_filter ; end
          end

          def filter_keys( opts )
            cattr_accessor :filtered_keys
            self.filtered_keys = opts
            #        class << self ; attr_accessor :filtered_keys ; end
          end

          def filter(entries)
            entries = Array( entries ).first.is_a?( FilterEntry ) ? Array( entries ) : FilterEntry.find( entries )
            return entries.inject( self ) { |r,v| r = r.scoped( :conditions => v.conditions( self ) ) }
          end

        end
      end




      # generate condition array/hash from key/op/val paris for *model*
      # checks if operator is allowed
      # tries to get column-name of an association by calling reflect_on_association or checking configured_filter (default)
      # returns an condition array like:
      #   [ "users.email LIKE :customer AND orders.id > :id", { :customer => "%bla%", :id => 7 } ]
      #
      def conditions( model )
        @model = model
        @includes = []
        sqlstr = "(" << Array( parse_column( self.key ) ).collect { |c|
          "#{c} #{check_operator( self.op )} :#{self.key.downcase}"
        }.join( " OR ") << ")"

        valhsh = { self.key.downcase.to_sym => self.op =~ /LIKE/ ? "%#{self.val}%" : "#{self.val}" }

        [ sqlstr, valhsh ]
      end


      # returns an anonymous scope for model current conditions
      def scope_for model
        cond = self.conditions( model )
        model.scoped( :conditions => cond, :include => @includes )
      end


      private

      # parse given column or association-name
      # checks if column is defined in *configured_filter*
      # if not, tries to identify column-name by calling *reflect_on_association*
      def parse_column( col )
        @includes ||= []
        # check if a configured filter exists
        if @model.respond_to?( :configured_filter )
          # check if column is configured
          if cf = @model.configured_filter[ col.to_sym ]
            @includes << col.to_sym
            return cf
          end
        end

        # filter was not configured, so check if column is an association
        if( assoc = @model.reflect_on_association( col.to_sym) )
          @includes << col.to_sym
          return "#{assoc.table_name}.#{col}"
        else
          return "#{@model.table_name}.#{col}"
        end
      end


      # checks if operator is allowed, if not an ArgumentError is raised
      def check_operator( op )
        return op if self.class.allowed_operators.include?( op )
        raise ArgumentError, "Operator No Allowed '#{op}'"
      end

    end



    # Zones (Country Codes)
    class Zone < ActiveRecord::Base

      named_scope :name_ordered, { :order => 'zones.country_name ASC' }

      class << self ;

        def for_select(*args)
          return [] unless args
          name_ordered.map do |m|
            args.map { |a| m.__send__( a ) }
          end
        end


      end
    end



    # Quicksteams (Header Tabs in the Admin-Backend
    class QuickSteam < ActiveRecord::Base
    end


    class Mailer < ActiveRecord::Base
      self.table_name = "config_mails"
      include Opensteam::System::FilterEntry::Filter

      named_scope :mailer_class, lambda { |mailer_class| { :conditions => { :mailer_class => mailer_class } } }
      named_scope :mailer_method, lambda { |mailer_method| { :conditions => { :mailer_method => mailer_method } } }
      named_scope :active, { :conditions => { :active => true } }

      def active? ; self.active ; end

      def activate!   ; self.update_attributes( :active => true )   ; end
      def deactivate! ; self.update_attributes( :active => false )  ; end


      def increment_messages ; self.increment!( :messages_sent ) ; end

      class << self ;

        def activate( klass, meth )
          mailer = mailer_class( klass.to_s ).mailer_method( meth.to_s )
          mailer.collect(&:activate!)
        end

        def deactivate( klass, meth )
          mailer = mailer_class( klass.to_s ).mailer_method( meth.to_s )
          mailer.collect(&:deactivate!)
        end

      end


    end





  end
end