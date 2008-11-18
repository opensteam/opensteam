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
  InventoryBase Module
  Holds the Inventory Logic (to be included into an actual Inventory Model)

  The Inventory Model has two main purposes:
  It provides inventory information for a product model, like price, storage, availability, etc

  And it acts as a join model between products and properties, and gives each characteristics/join-entry (like a "Shirt" in
  color "blue" or "red") its own inventory object (own price, storage, etc).
  The inventory entries are automatically created for each product-entry andor each product-property association.

=end
  module InventoryBase
    
    # Join Model for Inventories and Properties
    class InventoriesProperty < ActiveRecord::Base
      belongs_to :inventory, :class_name => "Opensteam::Models::Inventory"
      belongs_to :property, :class_name => "Opensteam::Base::PropertyBase"

      alias :real_property :property
      def property() return !property_type ? real_property : property_type.constantize.find(:all) ; end

    end
    

    def self.included(base)
      base.send( :extend,  ClassMethods )
      base.send( :include, InstanceMethods )

      base.class_eval do
        has_many :order_items, :class_name => "Opensteam::OrderBase::OrderItem"

        belongs_to :product, :polymorphic => true

        has_many :inventories_properties, :class_name => "Opensteam::InventoryBase::InventoriesProperty"
        has_many :properties, :through => :inventories_properties

        validates_presence_of :price, :storage

        # named_scope to get all inventories of a product depending on the given properties.
        named_scope :by_properties, lambda { |properties| { :include => :properties,
            :conditions => { "properties.id" => properties.collect(&:id) },
            :group => "inventories.id HAVING COUNT( inventories.id ) = #{properties.size}" } }

        # delegate name and descipription method calls to the associated product
        [:name, :description ].each { |m| delegate m, :to => :product }

      end

    end
    

    module ClassMethods

      # define property accessor methods, like "Inventory.find(:first).colors"
      def define_property_accessors
        Opensteam::Base::PropertyBase.properties.each do |accessor|
          self.class_eval do
            define_method( accessor.tableize ) { accessor.classify.constantize.find(:all) }
          end
        end
      end

    end


    module InstanceMethods

      # check if inventory-object is active
      def is_active?() active == 1 ; end

      # checks if inventory-object is available
      def is_available?() storage > 0 && is_active? ; end

      def products
        find(:all, :include => :product ).collect(&:product)
      end

    end

  end
    
    
end
  
  
  