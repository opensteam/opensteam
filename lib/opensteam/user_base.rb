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
	
	
  # UserBase
  #
  # Module for all User-Specific Classes
  #
  # 
  module UserBase
		
    class Address < ActiveRecord::Base
      
      belongs_to :customer, :class_name => 'Opensteam::UserBase::Customer'
      has_many :shipping_orders, :class_name => "Order", :foreign_key => "shipping_address_id"
      has_many :payment_orders , :class_name => "Order", :foreign_key => "payment_address_id"
		
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

          has_many :orders, :class_name => 'Admin::Sales::Order', :foreign_key => "user_id"
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

__END__

    class UserOLD < ActiveRecord::Base

      include Authentication
      include Authentication::ByPassword
      include Authentication::ByCookieToken

      validates_presence_of     :email
      validates_length_of       :email,    :within => 6..100 #r@a.wk
      validates_uniqueness_of   :email,    :case_sensitive => false
      validates_format_of       :email,    :with => RE_EMAIL_OK, :message => MSG_EMAIL_BAD

      validates_presence_of     :firstname
      validates_format_of       :firstname, :with => RE_NAME_OK, :message => MSG_NAME_BAD, :allow_nil => false
      validates_length_of       :firstname, :maximum => 100
    
      validates_presence_of     :lastname
      validates_format_of       :lastname, :with => RE_NAME_OK, :message => MSG_NAME_BAD, :allow_nil => false
      validates_length_of       :lastname, :maximum => 100
          
      attr_accessible :login, :email, :firstname, :lastname, :password, :password_confirmation
           
      class << self ;
              
        def new_or_existing_guest( attr = {} )
          attr.symbolize_keys!

          attr[:firstname] = attr[:lastname] = "guest"
          attr[:password] = attr[:password_confirmation] = "opensteam"
          returning( find_by_email( attr[:email] ) || new( attr ) ) do |guest|
            guest.profile = Profile.find_or_create_by_name( :name => "Guest" )
          end
          
        end
       
        
        def delete_by_profile profile_name
          delete( find(:all, :conditions => { "profiles.name" => profile_name }, :include => :profile ).collect(&:id) )
        end
        
        
        def authenticate(email, password)
          u = find_by_email(email) # need to get the salt
          u && u.authenticated?(password) ? u : nil
        end
      
      end

      belongs_to :profile, :class_name => 'Opensteam::UserBase::Profile'
      
      has_many :orders, :class_name => 'Admin::Sales::Order', :foreign_key => "user_id"
      has_many :addresses, :class_name => 'Opensteam::UserBase::Address', :foreign_key => 'user_id'

      
      named_scope :by_profile, lambda { |p| { :include => :profile, :conditions => "profiles.name = '#{p.to_s.classify}'" } }
      named_scope :order_by, lambda { |by| { :include => Opensteam::UserBase::User.osteam_configtable.default_include, :order => by, :conditions => "profiles.id = profiles.id" } }
      
      
      
      before_save :set_customer_profile
      
      def set_customer_profile
        unless self.profile
          self.profile = Profile.find_or_create_by_name(:name => "Customer" )
        end
      end

      
      def set_profile( p, autosave = false )
        self.profile = Profile.find_or_create_by_name( :name => p.to_s.classify )
        self.save if autosave
      end
      
      
      def method_missing(method, *args, &block)
        if method.to_s =~/^is\_(.+)\?$/
          return self.profile.name.classify.to_sym == $1.classify.to_sym
        end
        super
      end

      def old_password ; nil ; end
      
      def full_name ; [ firstname, lastname ] * " " ; end
      alias :to_s :full_name
      
      
      protected

    end
    

    
    class Profile < ActiveRecord::Base
      validates_presence_of   :name
      validates_uniqueness_of :name
      
      has_many :users, :class_name => 'Opensteam::UserBase::User'
      named_scope :by_name, lambda { |name| { :conditions => { :name => name }, :limit => 1 } }
      
      
      class << self ;
        def by_profile( name )
          by_name( name ).first
        end
      end
      
      
      
    end
    

  end
	
end

