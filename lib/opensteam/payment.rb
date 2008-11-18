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
  
  
  module Payment #:nodoc:

    
    # Default Extension for the PaymentTransaction Association in Opensteam::Payment::Base
    #
    # create a new payment_transaction object, yields the given block and save the response of the block
    # in the current-transaction.
    # The given block must return either a string (which is save in the transaction#message attribute) or
    # an object with the following attributes/methods:
    #   success?, authorization, message, params
    #
    # The PaymentTransaction Model is basically used to wrap the response of an ActiveMerchant Gateway.
    # The first parameter for the block must be a gateway. (See ActiveMerchant#Gateways for more information.)
    module PaymentTransactionExtension
      def process *args 
        
        args = args.first if args.is_a? Array
        
        create do |t|
          
          t.action = args[:action]
          t.amount = args[:amount]
          
          begin
            response = yield t.payment.gateway
            
            if response.is_a? String
              t.message = response
              break
            end
            
            t.success   = response.success? 
            t.reference = response.authorization
            t.message   = response.message
            t.params    = response.params
            t.test      = t.payment.gateway ? t.payment.gateway.test? : true
            
          rescue ActiveMerchant::ActiveMerchantError => e
            t.success   = false
            t.reference = nil
            t.message   = e.message
            t.params    = {}
            t.test      = t.payment.gateway.test?
            
          end

        end
      
      end
    
    end
    
    
    # Association Extension for Order#Payment Association
    module OrderExtension
      
      # create payment_object (according to proxy_owner.payment_type)
      def create_payment( attr = {}, &block )
        #     return unless proxy_owner.payment_type_valid?
        proxy_target << Opensteam::Payment::Base[ proxy_owner.payment_type.to_sym].create( attr, &block )
      end
      
      # build payment_object (according to proxy_owner.payment_type)
      def build_payment( attr = {}, &block )
        #     return unless proxy_owner.payment_type_valid?
        proxy_target << Opensteam::Payment::Base[ proxy_owner.payment_type.to_sym ].new( attr, &block )
      end

      def all_captured?
        empty? ? false : collect(&:payment_captured?).all? ;
      end
     
    end
    
    
    
    class Types < ActiveRecord::Base
      self.table_name = "payment_types"
      
      named_scope :active, { :conditions => { :active => true } }
      validates_uniqueness_of :name
      
      def enable! ; self.update_attribute :active, true ; end
      def disable! ; self.update_attribute :active, false ; end
      def active? ; self.active ; end
      def toggle! ; self.active? ? self.disable! : self.enable! ; end
      
      
      class << self ;
        
        def register_payment_types!
          
          Opensteam::Payment::Base.payment_types.each do |p|
            unless find_by_name( p.payment_id.to_s )
              create( :name => p.payment_id.to_s, :active => false, :klass => p.to_s )
            end
          end
          
        end
      end
    end
    
    
    # Base Class for all Payment Implementations
    #
    # 
    class Base < ActiveRecord::Base
      self.table_name = "payments"
      
      belongs_to :order, :class_name => 'Opensteam::Models::Order'
      
      
      has_many :transactions,
        :class_name => 'Opensteam::Payment::PaymentTransaction',
        :foreign_key => 'payment_id',
        :extend => Opensteam::Payment::PaymentTransactionExtension,
        :dependent => :destroy
      


      include Opensteam::StateMachine
      
      
      cattr_accessor :payment_types
      @@payment_types = []
      
      # the gateway class to use
      class_inheritable_accessor :gateway_class
      
      # the gateway login
      class_inheritable_accessor :gateway_user
      
      # the gateway password
      class_inheritable_accessor :gateway_password
      
      class_inheritable_accessor :display_name
      self.display_name = 'Payment Base Class'
      
      class_inheritable_accessor :display_description
      self.display_description = 'Base Class for all Payment Implementations'
      
      class_inheritable_accessor :payment_id
      self.payment_id = :base
      
      
      class << self
        
        def inherited(sub) #:nodoc:
          @@payment_types << sub
        end
        
        # retrieve a payment-implementation class using the :payment_id
        # Ex:
        #   class CreditCardPayment < Opensteam::Payment::Base
        #     self.payment_id = :credit_card
        #   end
        # 
        #   Opensteam::Payment::Base[ :credit_card ] # => CreditCardPayment
        #
        def [](payment_id)
          @@payment_types.find { |t| t.payment_id.to_sym == payment_id.to_sym }
        end
        
        
        
        def new_with_type( *attr, &block )
          if( h = attr.first).is_a? Hash and (type = h["type"] || h[:type] ) and ( klass = type.constantize ) != self
            raise "#{klass} is not a subclass of #{self}" unless klass < self
            return klass.new( *attr, &block )
          end
          new_without_type( *attr, &block )
        end
        alias_method_chain :new, :type
        
      end
      
      private
      
      # returns the current amount in cents
      def amount_in_cents
        ( amount * 100 ).to_i
      end
      
      
      
      
      
      
    end
    

    class PaymentTransaction < ActiveRecord::Base
      belongs_to :payment, :class_name => 'Opensteam::Payment::Base'
      serialize :params
      
      def action= a
        self[:action] = a.to_s
      end
      
    end
    
    
  end
  
   
end