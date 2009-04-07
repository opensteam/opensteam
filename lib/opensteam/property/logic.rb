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

module Opensteam::Property




  # Opensteam Logic for Property Model
  # 
  # This module is meant to be included into the actual Opensteam Property Model.
  # It provides the basic Property functionality and associations.
  #
  # A property object is used to describe a Product. (Like "Color", "Size", ..).
  # Based on the associated properties of a product, an inventory object can be built.
  # The inventory object is used to identify a product or a specific product-property configuration.
  #
  module Logic

    # holds all property classes
    mattr_accessor :property_klasses
    self.property_klasses = []



    class << self ;
      
      def included(base) #:nodoc:

        Opensteam::Dependencies.set_property_model( base )
        
        base.class_eval do
          has_many :inventories_properties, :class_name => "Opensteam::Inventory::InventoriesProperty"
          has_many :inventories, :through => :inventories_properties

          has_and_belongs_to_many :products
          has_and_belongs_to_many :property_groups

          #validates_uniqueness_of :value, :scope => :type

        end

        base.send( :extend, ClassMethods )
        base.send( :include, InstanceMethods )

      end
    end

    module ClassMethods #:nodoc:

      # returns all property klasses # => ["Color", "Size"]
      def property_classes
        Opensteam::Property::Logic.property_klasses
      end

      # save all property-classes into class_variable +property_klasses+
      def inherited(sub)
        super
        Opensteam::Property::Logic.property_klasses << sub.to_s
        Opensteam::Property::Logic.property_klasses.uniq!
      end
    end

    module InstanceMethods

      
      # sort properties
      def <=> (other) #:nodoc:
        self.id <=> other.id
      end
    end
    
  end

end
