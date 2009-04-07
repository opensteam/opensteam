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

module Opensteam::Inventory



  # Logic Module for the Opensteam Inventory Model
  #
  # This module is meant to be included into the actual Opensteam Inventory Model.
  #
  # An inventory object holds the price, quantity, etc .. for a product.
  # It is also used to given a certain product-property configuration a specific price, storage, etc.
  # When a customer buys a product, he actually buys an inventory-id.
  #
  # Inventory objects are used inside the shopping-cart, the wishlish and the order, to identify the product.
  # (So the inventory-object can be used as the interface to a legacy system.)
  # 
  # 
  module Logic

    class << self ;

      def included(base)
                
        raise ArgumentError, "Can't include #{self} into more than one Inventory-Models. Use STI instead!" if
          self.included_in_classes.reject { |s| s == Opensteam::Inventory::Base }.size > 1
        
        Opensteam::Dependencies.set_inventory_model( base )
        
        
        
        base.send( :extend,  ClassMethods )
        base.send( :include, InstanceMethods )

        base.class_eval do
          
          # product association
          belongs_to :product, :class_name => "Opensteam::Models::Product"
          
          # has_many :through association for properties
          has_many :inventories_properties, :class_name => "Opensteam::Inventory::InventoriesProperty"
          has_many :properties, :through => :inventories_properties, :class_name => "Opensteam::Models::Property"

          # tax_group association, used for tax calculation
          belongs_to :tax_group, :class_name => 'Opensteam::Sales::Money::Tax::ProductTaxGroup'

          validates_presence_of :price, :storage

          # find inventories based on given properties
          named_scope :by_properties, lambda { |properties|
            { :include => :properties,
              :conditions => { "properties.id" => properties.collect(&:id) },
              :group => "inventories.id HAVING COUNT( inventories.id ) = #{properties.size}" }
          }
        end

      end

    end

    module ClassMethods
      def default_attributes #:nodoc:
        { :price => 0.0,
          :storage => 0,
          :active => false,
          :back_ordered => false }
      end

    end

    module InstanceMethods

      # returns true if inventory is active and storage > 0
      def is_available?
        self.active && self.storage > 0
      end

    end

    
  end
end