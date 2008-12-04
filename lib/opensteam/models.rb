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
      # order collection by given column (e.g. "containers.id" )
      named_scope :order_by, lambda { |by| { :include => Order.osteam_configtable.default_include, :order => Array(by).join(",") , :conditions => "users.id = users.id" } }

      # get orders by given user
      named_scope :by_user, lambda { |user_id| { :include => [:customer ], :conditions => { :user_id => user_id } } }


      def to_ext_xml options = {}
        options[:indent] ||= 2
        options[:builder] || Builder::XmlMarkup.new( :indent => options[:indent] )
        options[:root] = "Item"
        options[:skip_instruct] = true
        options[:dasherize] = false
        {
          :id => self.id,
          :customer => self.customer.email,
          :order_items => self.items.size,
          :shipping_address => self.shipping_address.full_address,
          :payment_address => self.payment_address.full_address,
          :state => self.state.to_s,
          :created_at => self.created_at,
          :updated_at => self.updated_at,
          :editor_url => "/admin/sales/orders/#{self.id}"
        }.to_xml( options )

      end

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