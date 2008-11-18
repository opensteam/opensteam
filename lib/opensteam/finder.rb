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

$:.unshift(File.dirname(__FILE__)) unless
$:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'opensteam/config'

module Opensteam


  # Finder Module
  #
  # provides methods to find products and properties
  # TODO: replace this with a Product/Property class for all product and property models (like an ActiveRecord::Base class without a table)
  module Finder
    
		
    def self.included(base) #:nodoc:
      base.extend(ClassMethods)
    end
		
    module ClassMethods
			
      
      # returns all product classes (constantized)
      def find_product_klasses
        find_product_tables.collect(&:classify).collect(&:constantize)
      end
      
    
      # method is invoked before adding a product to the cart
      #
      # finds the product, specified in h and saves the inventory, based on the
      # selected properties, in the "selected_inventory" var.
      # 
      # h is the params[:product] Hash,:
      #   params[:product] = { :class => "ProductClass", :id => 1, 
      #     :properties => { "Color" => 2, "Size" => 5 } 
      #   }
      #
      def find_product_with_inventory( h )

        product = find_product_by_id( h[:class], h[:id] )
        props = h[:properties] ? h[:properties].collect { |x| find_property_by_id( x.first, x.last ) } : []
        product.selected_inventory = product.inventories( props )
        product
        
      end
      
      
      # find all product tables (tables prefixed with Opensteam::Config::PRODUCT_BASE_TABLE_PREFIX)
      # TODO : implement paginate for finder
      def find_product_tables
        find_tables("product")
      end
      
      
      # find all products
      def find_products
        find_product_tables.inject([]) { |r,v| r += v.classify.constantize.find(:all) }
      end

      
      # find property tables
      def find_property_tables
        Opensteam::Base::PropertyBase.properties.collect(&:tableize)
        #        find_tables("property")
      end
			
      # find all properties
      def find_properties
        Properties.find(:all)
        #        find_property_tables.inject([]) { |r,v| r += v.classify.constantize.find(:all) }
      end
		
      
      # find all products of the specified Class
      def find_product(klass)
        contantize_pro(:product, klass).find(:all)
      end
      
      # find a product specified by klass and id
      def find_product_by_id(klass,id)
        return nil if id.empty?
        contantize_pro(:product,klass).find(id)
      end
      
      # find all properties of the specified Class
      def find_property(klass)
        contantize_pro(:property,klass).find(:all)
      end
      
      # find a property by klass and id
      def find_property_by_id(klass,id)
        return nil if id.empty?
        contantize_pro(:property, klass).find(id)
      end
      
      
			
      # checks if the "inventories_properties" table exists
      def inventories_properties_exist?
        ActiveRecord::Base.connection.tables.include?( "inventories_properties" )
        #        not ActiveRecord::Base.connection.select_all("SHOW TABLES LIKE 'inventories_properties'").empty?
      end
			
      # checks if the properties table exists
      def properties_table_exists?
        ActiveRecord::Base.connection.tables.include?( "properties" )
        #        not ActiveRecord::Base.connection.select_all("SHOW TABLES LIKE 'properties'").empty?
      end

      
      private
      

      def contantize_pro(s, klass ) #:nodoc:
        if klass.classify.constantize.respond_to?("is_#{s.to_s}?") && klass.classify.constantize.send("is_#{s.to_s}?")
          return klass.classify.constantize
        else
          raise Opensteam::Config::Errors::NotAProduct, "#{klass} is not a product, sorry .." if s == :product
          raise Opensteam::Config::Errors::NotAProperty, "#{klass} is not a property, sorry .." if s == :property
        end
      end
      
      def find_tables(type) #:nodoc:
        type = type.to_s
        prefix = 
          case type
        when "property"
          Opensteam::Config::PROPERTY_BASE_TABLE_PREFIX.to_s
        when "product"
          Opensteam::Config::PRODUCT_BASE_TABLE_PREFIX.to_s
        end
        
        tables = ActiveRecord::Base.connection.tables.select { |s| s =~ /^#{prefix}\_.+$/ }.collect { |t|
          t.gsub("#{prefix}_", "" ) }

        #        tables = ActiveRecord::Base.connection.select_all("SHOW TABLES LIKE '#{prefix}\\_%'").collect(&:values).flatten.collect {
        #          |t| t.gsub("#{prefix}_", "") }
      end
			
			
			
			
		
    end #class methods
		
  end #Finder


  # dummy class to access the finder-methods without including the module.
  class Find
    include Opensteam::Finder
  end

  
  
end #Opensteam
