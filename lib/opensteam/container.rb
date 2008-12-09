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
  

  # Container Module
  module Container
    

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
    
    
    # Items for Container Class
    # used for CartItems, OrderItems, etc
    #
    # provivdes functionality to increment/decrement/set quantity.
    # If quantity == 0, item destroys itself.
    #
    # implements +method_missing+ to delegate all unknown method-calls to the (polymorphic) item-object.
    class Item < ActiveRecord::Base
      
      def self.table_name ; "container_items" ; end


      before_create :init_price, :init_quantity
      after_save :check_quantity
      before_save :update_total_price
  
      belongs_to :container, :class_name => 'Opensteam::Container::Base',
        :counter_cache => "items_count"
      
      

      belongs_to :item, :polymorphic => true
  
      
      belongs_to :invoice, :class_name => 'Opensteam::Models::Invoice', :counter_cache => "items_count"
      belongs_to :shipment, :class_name => 'Opensteam::Models::Shipment', :counter_cache => "items_count"
      
      
      # increment quantity
      def incr ; self.increment!( :quantity, 1 ) ; end
  
      # decrement quantity
      def decr ; self.decrement!( :quantity, 1 ) ; end
  
  
      # set quantity and save item
      def set_quantity( qnt )
        self.quantity = qnt
        save
      end
  
      # delegate all missing methods to item, if item responds
      def method_missing(name, *args, &block )
        self.item.respond_to?( name ) ? self.item.__send__( name, *args, &block ) : super
      end
  
      private
      
      # init quantity
      def init_quantity
        self.quantity = 1 ;
        update_total_price
      end


      
      def init_price
        self.price = self.item.price
      end
      

      def update_total_price
        self.total_price = self.quantity * self.price
      end
      
      
      # if quantity == 0, destroy yourself
      def check_quantity
        if self.quantity <= 0
          self.destroy
        end
      end
      
      
  
    end
    
    
  end
end

Cart = Opensteam::Container::Cart
