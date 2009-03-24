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
          require_dependency 'opensteam/models'
          
          # order association
          has_many :orders, :class_name => 'Opensteam::Models::Order', :foreign_key => "user_id"
          
          # address assocation
          has_many :addresses, :class_name => 'Opensteam::UserBase::Address', :foreign_key => 'user_id'

          # quicksteam association for admin backend
          has_many :quick_steams, :class_name => "Opensteam::System::QuickSteam", :foreign_key => "user_id"

          def full_name ; [ firstname, lastname ] * " " ; end
          alias :to_s :full_name


          ## named_scopes
          named_scope :by_profile, lambda { |profile_name| { :include => :user_roles, :conditions => ["user_roles.name = ?", profile_name ] } }
          named_scope :role, lambda { |role| { :include => :user_roles, :conditions => ["user_roles.name = ?", role.downcase ] } }

          # attributes
          attr_accessor :old_password, :firstname, :lastname
          attr_accessible :old_password, :firstname, :lastname


          ## callbacks
          after_create :set_customer_role
          protected :set_customer_role

        end

      end

      module ClassMethods
      end

      module InstanceMethods
        
        def firstname ; self.name.split(" ").first ; end
        def lastname ; self.name.split(" ").last ; end
        
        # marks the user as 'customer'
        def set_customer_role
          self.user_roles << UserRole.find_or_create_by_name( "customer" )
        end
        
        # adds the UserRole +profile+ to users user_roles
        def profile=(profile)
          profile = UserRole.find_by_name( profile.to_s ) if ( profile.is_a?( String ) || profile.is_a?( Symbol ) )
          self.user_role_ids << profile.id if profile
        end
        
        # checks if user has the specific +role+ (without returning always true, if user is an admin)
        def has_specific_role?( role )
          @_list ||= self.user_roles.collect(&:name)
          @_list.include?( role.to_s )
        end
        
        
      end

    end

  end
end