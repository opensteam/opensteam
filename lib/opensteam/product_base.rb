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

module Opensteam
  
=begin rdoc

ProductBase Module

Provides functionality for opensteam Products.
To use a clasa/model (inside your Rails application) as an opensteam product class
either use the +opensteam :product+ macro or inherit from Opensteam::Base::ProductBase.

Example 1:

  class DesktopComputer < ActiveRecord::Base
    opensteam :product
  end

Example 2 (Object Oriented):

  class DesktopComputer < Opensteam::Base::ProductBase
  end


All product-tables are/must be prefixed with "product_" (default). This used
to find all product tables.

With the base-class Opensteam::Base::ProductBase or through the
+opensteam :product+ macro, a model gets all the functionality needed to work
with the opensteam core:

- association to inventories (Opensteam::InventoryBase). Used for prices, storages and
  associated properties.
- association to properties (through inventories)
- Opensteam::System::FilterEntry::Filter, used to filter database entries in the Opensteam Backend

=end
  
  module ProductBase
  
    # array to hold extra modules to be included into each product class
    mattr_accessor :product_modules
    self.product_modules = []
    
    class << self
      
      # specify modules to automatically be included into each product class
      # 
      #   module ModuleYZ
      #     def say_hello ; puts "hello" ; end
      #   end
      #   
      #   Opensteam::ProductBase.extend_product( ModuleYZ )
      #
      #   class ProductA < ActiveRecord::Base
      #     opensteam :product
      #   end
      #
      #   p = ProductA.new
      #   p.say_hello # => "hello"
      #
      #
      def extend_product( mod )
        self.product_modules << mod
      end
      
    end
    
    module ClassMethods #:nodoc:
      
      
      # get the table_prefix for all Opensteam Products
      # per default all product tables are prefixed with "product_"
      def table_prefix() Opensteam::Config::PRODUCT_BASE_TABLE_PREFIX.to_s ; end
      def table_name() self.table_prefix + "_" + self.to_s.tableize ; end
      
      # define properties the product is allowed to have
      def has_property(p = nil, opt = nil )
        p ? ( self._has_property ||= {} ).store(p, opt) : ( self._has_property ||= {} )
      end
  
      
      def has_product(p) #:nodoc:
        (self._has_product ||= []) << p if p 
      end
      
      
      
      # get all property-objects (records) for current product
      # to define the properties the product is allowed to have use:
      # - *has_property :property_class* in ProductModel
      # default: all properties
      #
      def get_has_property
        (self._has_property.nil? ? self.find_property_tables : self._has_property).inject({}) { |r,v|
          r.merge!( { v => v.to_s.classify.constantize.find(:all) } ) unless v.first == :none } || {}
      end
	
      # get all product-objects (records) for current product (used for bundle-products)
      # to define the products the current bundle-product is allowed to have use:
      # - *has_product :peoduct_model* in ProductModel
      # default: no products
      #
      def get_has_products
        products = (self._has_product || []).inject({}) { |r,v|
          r.merge!( { v => v.to_s.classify.constantize.find(:all) } ) }  || {}

        products.delete(self.to_s.tableize) 

        products
      end
      
      
    end
  
  
  
    def self.included(base)
      base.extend ClassMethods
      base.send( :include, InstanceMethods )
      base.send( :include, *self.product_modules ) unless self.product_modules.empty?

      # call class-methods
      base.class_eval do
        
        include Opensteam::Base::Helper
        include Opensteam::Finder
  #      include Opensteam::System::FilterEntry::Filter
  
        has_many :properties, :class_name => "Opensteam::Base::PropertyBase",
          :finder_sql => 'SELECT properties.* FROM properties ' +
          'INNER JOIN inventories_properties ON inventories_properties.property_id = properties.id ' +
          'INNER JOIN inventories ON inventories.id = inventories_properties.inventory_id ' +
          'WHERE (( inventories.product_type = "#{self.class}" ) AND ( inventories.product_id = #{id} ) ) ',
          :extend => Opensteam::Base::PropertiesExtension,
          :uniq => true
        
        # inventory association
        has_many :inventories, :as => :product,
          :extend => Opensteam::Base::ExistByPropertiesExtension,
          :class_name => "Opensteam::Models::Inventory"

        has_many :inventories_properties, :through => :inventories, :include => :property
        
  
        # holds the properties the product is allowed to have
        # used for view
        class_inheritable_accessor :_has_property
			
        # holds the products the bundle-product is allowed to have
        # used for view
        class_inheritable_accessor :_has_product
      
        attr_accessor :selected_inventories

        attr_accessor :property_errors
        
        alias_method :real_inventories, :inventories

        def inventories( a = [] ) 
          #puts "********* IIIIIIINNNNNVENTORRRIEEEEEEEESSS ***********  "
          a.empty? ? real_inventories : real_inventories.collect { |x| (x.properties.sort - a.sort).empty? ? x : nil }.compact ;
        end

      end

    end
    
    module InstanceMethods
      
      
      
      def selected_inventory() @selected_inventories ||= nil ; end
      def selected_inventory=(i) @selected_inventories = i ; end 
      
      def property_errors() @property_errors ||= [] end
      def property_errors=(a) @property_errors = a end

      def is_available?
        selected_inventories.active && selected_inventories.storage > 0
      end
    
      def products ; [] ; end 
      
      # set property associations for the current product
      # p can either be a hash or an array of properties.
      #
      #   p = [ PropertyA, PropertyB]
      #   p = [ [ PropertyA, PropertyB], [ PropertyA, PropertyC] ]
      #   
      #   p = { "Size" => { "1" => 1 },
      #         "Color" => { "32" => 1 } }
      #
      # for each property (or set of properties) an invenvory-object is created and associated
      # with the properties.
      #
      # inventoy-objects which are currently associated with the product and do not
      # match the properties (p) are deleted.
      #
      # used in the admin-views, to update the product-property associations.
      #
      def set_properties2=(p)
        save
      
      
        if p.empty? && properties.empty?
          inventories << Opensteam::Models::Inventory.create( :price => 0, :storage => 0, :active => 0 )
          return
        end

        if p.kind_of? Hash
          prop = {}
          p.each_pair { |k,v| 
            if ( pr = k.classify.constantize ).ancestors.include?( Opensteam::PropertyBase )
              prop[ k.to_sym ] = v.collect { |x| pr.find( x ) }
            else
              raise Opensteam::Config::Errors::NotAProperty, "'#{k.classify}' is not a property"
            end }
          prop = prop.values.perm.collect(&:sort)
        else
          prop = p
        end
      
      
        inventories.each do |i|
          i.destroy unless prop.include? i.properties.sort
        end

        add_properties(prop)

        save
      end
    

    
      def set_properties= p
        if p.empty? && properties.empty?
          self.inventories.build( :price => 0, :storage => 0, :active => 0 )
          return
        end
  
        if p.is_a? Hash
          prop = {}
        
          p.each_pair { |k,v|
            if ( pr = k.classify.constantize ) < Opensteam::PropertyBase
              prop[ k.to_sym ] = v.collect { |x| pr.find( x ) }
            else
              raise Opensteam::Config::Errors::NotAProperty, "'#{k.classify}' is not a property"
            end }
          prop = prop.values.perm.collect(&:sort)
        else
          prop = p
        end
      
        inventories.each do |i|
          i.destroy unless prop.include? i.properties.sort
        end

        prop.each do |pp|
          if self.inventories.by_properties( pp.is_a?( Array ) ? pp : [pp] ).empty?
            #       unless self.inventories.by_properties?( pp.is_a?( Array ) ? pp : [pp] )
            self.inventories.build( :price => 0, :storage => 0, :active => 0, :properties => pp )
          end
        end
  
      end
      alias :properties= :set_properties=
    
    
      # Add properties to the current product.
      # For every property (or set of properties) an inventory-object is created (unless an inventory-object for the property (or set of properties) already exists).
      def add_properties(prop)
        prop.each do |pp|
          unless self.inventories.exist_by_properties?( pp.is_a?( Array ) ? pp : [pp] )
            i = Opensteam::Models::Inventory.create( :price => 0, :storage => 0, :active => 0 )
            i.properties << pp
            inventories << i
          end
        end
      
      end
    
    
      # delete properties from the current product
      def del_properties(p)
        p = Array(p)
        return nil if p.empty?
        return ( i = inventories( p ) ) ? i.collect(&:destroy) : nil ;
      end

    
      # clear all properties for the current product
      def clear_properties
        inventories.collect(&:destroy)
      end
    

      
      # DEPRECATED !!!!!
      # 
      # 
      # set products-association for object (virtual attributes)
      # used for product-create/edit-view
      # saves the product first, due to "unsaved associations" error
      #
      def set_products=(p)
        save
        products.delete_all
        p.each_pair do |k,v|
          v.each_pair { |id,n| products << k.classify.constantize.find(id) rescue nil }
        end
      end
    end
    

  end
  
  
  
  
    
    
end
  
  
  