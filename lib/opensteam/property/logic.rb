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

  module Logic

    mattr_accessor :property_klasses
    self.property_klasses = []



    class << self ;
      def included(base)
        base.class_eval do
          has_many :inventories_properties, :class_name => "Opensteam::Inventory::InventoriesProperty"
          has_many :inventories, :through => :inventories_properties

          has_and_belongs_to_many :products
          has_and_belongs_to_many :property_groups

          validates_uniqueness_of :value, :scope => :type

        end

        base.send( :extend, ClassMethods )
        base.send( :include, InstanceMethods )

      end
    end

    module ClassMethods #:nodoc:

      def property_classes
        Opensteam::Property::Logic.property_klasses
      end

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
