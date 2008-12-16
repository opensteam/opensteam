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


  # Model Namespace
  # contains openSteam specific models, like Order, Inventory, Invoice, Shipment, etc
  #
  # The opensteam specific logic is included using modules, like Openteam::OrderBase
  #
  # This is meant to be replaced by actual models inside a Rails Application
  #
  module Models

    # Order Model
    # see Opensteam::OrderBase for more information
    class Order < Opensteam::Container::Base
      include Opensteam::OrderBase
     
      # get orders by given user
      named_scope :by_user, lambda { |user_id| { :include => [:customer ], :conditions => { :user_id => user_id } } }
    end


    # Inventory Model
    # see Opensteam::InventoryBase for more information
    class Inventory < ActiveRecord::Base
      include Opensteam::InventoryBase

    end


    # Shipment Model
    # see Opensteam::ShipmentBase for more information
    class Shipment < ActiveRecord::Base
      include Opensteam::ShipmentBase
      
    end


    class Invoice < ActiveRecord::Base
      include Opensteam::InvoiceBase
      
    end


  end
end