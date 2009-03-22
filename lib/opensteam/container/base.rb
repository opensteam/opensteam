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


module Opensteam::Container


  # Container Base Class
  #
  # This Class is used to provide container functionality for Cart/Order/Wishlist/... models using STI.
  # A container class has many items (Opensteam::Container::Item) and belongs to a customer
  #
  # TODO: check self.abstract == useful
  class Base < ActiveRecord::Base
    def self.table_name ; "containers" ; end

  
    has_many :items, :class_name => "Opensteam::Container::Item",
      :foreign_key => 'container_id',
      :dependent => :destroy
  
    belongs_to :customer, :class_name => 'Opensteam::UserBase::User'
  
  
    # move all items from container +c+ to current container +self+
    def move_items_from c
      c.items.each do |v|
        v.update_attribute( :container, self )
      end
    
    end
  
    # copy all items from container +c+ to current container +self+
    def copy_items_from c
      c.items.each do |v|
        items.build( v.attributes )
      end
    end
  
  end

end
