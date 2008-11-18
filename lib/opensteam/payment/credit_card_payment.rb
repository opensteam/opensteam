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
  module Payment
    

    #require 'active_merchant'

    class CreditCardPayment < Base
      self.display_name = "CreditCard Payment"
      self.payment_id = :credit_card
      
      #self.gateway_class = ActiveMerchant::Billing::BrainTreeGateway
      self.gateway_class = nil #ActiveMerchant::Billing::BogusGateway
      self.gateway_user = 'demo'
      self.gateway_password = 'password'
      self.observers =  []
      
      serialize :data
      
      attr_accessor :credit_card
      
      # validates_presence_of :credit_card
      

      def initialize(*args, &block )
        self.credit_card = ActiveMerchant::Billing::CreditCard.new
        super( *args, &block )
      end
      
      
      def gateway
        self.class.gateway_class.new( :login => self.class.gateway_user, :password => self.class.gateway_password )
      end
      
      # inits a new credit card and assigns it to current payment object
      def set_credit_card=(fields)
        #self.credit_card = CreditCard.new( fields )
        fields.update( :type => fields.delete(:brand) ) if fields[:brand]
        self.credit_card = ActiveMerchant::Billing::CreditCard.new( fields )
        self.data = { :number => self.credit_card.display_number,
          :first_name => self.credit_card.first_name,
          :last_name => self.credit_card.last_name }
      end
      
      
      # authorize amount and credit_card at payment gateway
      def authorize( amount = nil, options = {} )
        self.amount = amount || self.order.total_price
        #self.credit_card.decrypt_number
        
        transactions.process( :action => :authorize, :amount => amount_in_cents ) do |gw|
          gw.authorize( amount_in_cents, self.credit_card, options )
        end
        
      end
      
      
      # capture amount from authorization
      def capture( amount, authorization, options = {} )
        self.amount = amount || self.order.total_price
        
        transactions.process( :action => :capture, :amount => amount ) do |gw|
          gw.capture( amount_in_cents, authorization, options )
        end
        
      end
      
      
      # purchase amount from credit_card
      def purchase( amount = nil, options = {} )
        self.amount = amount || self.order.total_price
        # self.credit_card.decrypt_number

        process :purchase, amount_in_cents, self.credit_card, options
      end
      

      
      
      
      private

      def process action, amount, credit_card,options
        transactions.process( :action => action, :amount => amount ) do |gw|
          gw.__send__( action, amount, credit_card, options )
        end
      end
      

      
      def validate
        if credit_card
          errors.add( :credit_card, "not valid" ) unless credit_card.valid?
        end
      end
        
      # charge credit card transaction
        
      #                    
      #        response = gateway.purchase( amount_in_cents, credit_card )
      #            
      #        self.test = response.test?
      #        self.reference = response.authorization
      #        self.message = response.message
      #        self.receipt = response.receipt
      #            
      #        if !response.success?
      #          errors.add_to_base( self.message )
      #          return false
      #        end
    end
      
      
  
    module States
      
      module PaymentAuthorized
        include Opensteam::StateLogic::Mod
      end
      
      module PaymentCaptured
        include Opensteam::StateLogic::Mod
      end
      
      module PaymentDeclined
        include Opensteam::StateLogic::Mod
      end
      
      module PaymentFailed
        include Opensteam::StateLogic::Mod
      end
      
    end

    
#    # CreditClass Model
#    # persist CreditCards
#    class CreditCard < ActiveRecord::Base
#
#      include ActiveMerchant::Billing::CreditCardMethods
#      include Opensteam::Security::Encryption
#  
#      cattr_accessor :password
#      attr_accessor :number
#      
#      def verification_value? ; false ; end
#
#      
#      def to_xml options = {}
#        super options.merge( :except => [ :data, :salt ] )
#      end
#
#      
#      def encrypt_number
#        self.data = encrypt( number, password, salt )
#      end
#  
#      
#      def decrypt_number
#        self.number = decrypt( data, password, salt )
#      end
#  
#   
#      private
#  
#      before_create :store_last_digits, :generate_salt, :encrypt_number
#      validates_presence_of :first_name, :last_name, :brand
#  
#      def store_last_digits
#        self.last_digits = self.class.last_digits( number )
#      end
#  
#      def generate_salt
#        self.salt = [ rand(2**64 - 1)].pack("Q")
#      end
#  
#      def validate
#        errors.add( :year, "is invalid") unless valid_expiry_year?( year )
#        errors.add( :month, "is invalid") unless valid_month?( month )
#        # errors.add( :number, "is invalid") unless self.class.valid_number?( number )
#        if password.blank?
#          errors.add_to_base( "Unable to encrypt or decrypt data without password")
#        end
#      end
#
#    end
#    
#    
#    
    
    
    

    
    
    
  end
  
  
  
  
end