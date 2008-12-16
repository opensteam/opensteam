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

PropertyBase Module

Defines all the Property-specific methods and variables.
Used for the Property Base Class (STI)

=end
  
  module PropertyBase
  
    module ClassMethods #:nodoc:

      def table_name() "properties" ; end
      
      def properties
        @properties ||= []
      end

      def configured_grid
        self.columns.collect(&:name).inject({}) { |r,v| r.merge({ v.to_sym => v.to_sym }) }.merge(
          { :editor_url => :editor_url
          }
        )
      end
      
      # save all subclasses in the properties-variable
      def inherited(property)
        properties << property.to_s
        super
      end
      
    end

    module InstanceMethods
    end
  
  
    def self.included(base)
      base.send( :extend,  ClassMethods )
      base.send( :include, InstanceMethods )
        
      base.class_eval do
        include Opensteam::Base::Helper
        include Opensteam::Finder

        has_many :inventories_properties,
          :class_name => "Opensteam::InventoryBase::InventoriesProperty",
          :foreign_key => "property_id"
        
        has_many :inventories, 
          :class_name => "Opensteam::Models::Inventory",
          :through => :inventories_properties
        
      end
    end
      
      
    def only_properties() #:nodoc:
      is_property? ? self : nil
    end
      
    # sort properties
    def <=> (other) #:nodoc:
      self.id <=> other.id
    end

  end
  
end
  
  
