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

module Opensteam
	
	
  # UserBase
  #
  # Module for all User-Specific Classes
  #
  # 
  module UserBase
		
    class Address < ActiveRecord::Base


      belongs_to :customer, :class_name => 'User'
      has_many :shipping_orders, :class_name => "Opensteam::Models::Order", :foreign_key => "shipping_address_id"
      has_many :payment_orders , :class_name => "Opensteam::Models::Order", :foreign_key => "payment_address_id"
		
      has_many :shipments
      has_many :invoices
      
      validates_presence_of :city, :postal, :street, :country
		
			
      # get all orders for current address
      def orders
        self.shipping_orders | self.payment_orders
      end

      def zip ; postal ; end
      
      def land ; country ; end
      def land=(l) ; country = l ; end

      def to_a; [ firstname, lastname, street, zip, city, country ] ; end
      def full_address ; to_a * (", ") ; end

      def full s = "\n" ; to_a * s ; end
      
      alias :to_s :full_address

    end
    
    
    require 'digest/sha1'

    module UserLogic

      def self.included(base)
        base.send( :extend, ClassMethods )
        base.send( :include, InstanceMethods )

        base.class_eval do
          # belongs_to :profile, :class_name => 'Opensteam::UserBase::Profile'
          require_dependency 'opensteam/models'
          

          has_many :orders, :class_name => 'Opensteam::Models::Order', :foreign_key => "user_id"
          has_many :addresses, :class_name => 'Opensteam::UserBase::Address', :foreign_key => 'user_id'

          has_many :quick_steams, :class_name => "Opensteam::System::QuickSteam", :foreign_key => "user_id"

          def full_name ; [ firstname, lastname ] * " " ; end
          alias :to_s :full_name


        end

      end

      module ClassMethods
      end

      module InstanceMethods
      end

    end

  end
end