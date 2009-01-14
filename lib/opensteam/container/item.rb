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