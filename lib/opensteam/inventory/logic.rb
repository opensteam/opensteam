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

  module Logic

    class << self ;

      def included(base)
        base.send( :extend,  ClassMethods )
        base.send( :include, InstanceMethods )

        base.class_eval do
          belongs_to :product #, :class_name => "::Product"
          has_many :inventories_properties, :class_name => "Opensteam::Inventory::InventoriesProperty"
          has_many :properties, :through => :inventories_properties

          belongs_to :tax_group, :class_name => 'Opensteam::Sales::Money::Tax::ProductTaxGroup'

          validates_presence_of :price, :storage

          named_scope :by_properties, lambda { |properties|
            { :include => :properties,
              :conditions => { "properties.id" => properties.collect(&:id) },
              :group => "inventories.id HAVING COUNT( inventories.id ) = #{properties.size}" }
          }
        end

      end

    end

    module ClassMethods
      def default_attributes
        { :price => 0.0,
          :storage => 0,
          :active => false,
          :back_ordered => false }
      end

    end

    module InstanceMethods

      def is_available?
        self.active && self.storage > 0
      end

    end

    
  end
end