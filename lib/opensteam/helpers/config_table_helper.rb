#	openSteam - http://www.opensteam.net
#  Copyright (C) 2008  DiamondDogs Webconsulting
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

module Opensteam::Helpers #:nodoc:
  
  
  module ConfigTableHelper
    
    def self.included(base)
      base.extend(ClassMethods)
      base.class_eval do
        include InstanceMethods
        
      end
      
    end
    
    module ClassMethods
      
      def opensteam_filter(name, *args, &block )
        @osteam_configtable = Opensteam::Helpers::ConfigTableHelper::Base.new( name, *args )
        @osteam_configtable.instance_eval(&block) if block_given?
        
        class << self ; attr_accessor :osteam_configtable ; end
     
      end
      
    end
    
    module InstanceMethods
    end
    
    
    
    class Base < ActionView::Base
      
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::FormTagHelper
      
      attr_accessor :name, :default_include, :columns, :order_column
      
      def initialize( name, *args )
        #  args = args.first if args.is_a?(Array)
        @name = name
        @default_include = [] #args[:default_include] || []
        @columns = []
      end
      
      def include_associations(arr)
        @default_include = arr
      end
      
      def column(id, *args)
        @columns << Column.new( id, *args )
      end
      
      def default_order_column(id)
        @order_column = id
      end
      
      def [](id)
        @columns.find { |s| s.id.to_s == id.to_s }
      end
      
      def table_header( opts = {}, &block )
        html_options = opts[:html]
        content_tag( :thead, {} ) do
          content_tag( :tr, {} ) do
            @columns.collect do |c|
              content_tag( :th, html_options ) do
                content_tag( :div, { :style => "margin-left:3px; margin-right:3px;"} ) do
                  block.call( c )
                end
              end
            end
          end
        end
      end
      
    
        
        

    end
    
    class Column
      attr_accessor :name, :order, :sql, :id
      def initialize(id, *args )
        @args = args.is_a?( Array ) ? args.first : args
        @id = id
        @order = @args[:order] || @args[:sql]
        @sql = @args[:sql] || @args[:order]
        @name = @args[:name]
        @method = @args[:method]
      end
      
      def order
        @order.is_a?( Array) ? @order.join(",") : @order
      end
      
      def sort
        if @method
          return Proc.new { |a,b| a.__send__( @id ).__send__(@method) <=> b.__send__( @id ).__send__( @method ) }
        end
        return @order
      end
      
      
      
    end
    
    
    module HelperMethods
      
      def osteam_sort_table( mdl, opts = {}, &block )
        mdl = mdl.to_s.classify.constantize unless mdl.is_a?( Class )
        config_table = mdl.osteam_configtable
        
        content = capture( config_table, &block )

        html_options = opts[:html] || {}
        
        concat( 
          content_tag( :div, { :class => 'osteam_configured_table_div' } ) do
            content_tag( :table, html_options ) do
              content
            end
          end, block.binding )
        
      end
      
    end
    
  end
      
      
      
      
      
    
    

end
