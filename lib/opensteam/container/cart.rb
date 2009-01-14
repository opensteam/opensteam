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
 
  # Shopping Cart implementation
  # SubClass of Opensteam::Container::Base
  #
  # provides functionality to
  # - access items (array-like)
  # - create/update/delete items
  # - set/increment/decrement item quantity
  #
  class Cart < Opensteam::Container::Base
    
    # access items as array
    def []( id ) ; items[id.to_i] ; end

    # push/add item to container
    # if item exists, increment quantity
    def push( item )
      unless( i = find_item( item ) )
        items.create( :item => item )
      else
        i.incr
      end
    end

    # TODO: fix this update_tax method!!!!!!
    def update!
      update_tax( :country => "Austria" )
    end
    
    
    # access index of items
    def index(i)
      @items.index(i)
    end
    
    
    # find +item+
    def find_item( item )
      Array(items).find { |i| i.item == item }
    end

    
    def total_price
      items.collect(&:total_price).sum
    end

    # set quantity for items in +h+ (hash)
    #   container.set_quantity = { "0" => 123, "1" => 345 }
    # where key is the array index of +items+
    def set_quantity=(h)
      h.each_pair { |k,v| self.items[k.to_i].set_quantity(v) }
    end

    
    # alias for push
    alias :<< :push
    alias :add :push
    
  end
     
    
end
