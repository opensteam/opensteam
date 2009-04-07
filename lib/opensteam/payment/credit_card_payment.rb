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
  module Payment
    

    # implements the Payment Class for paying via credit-card
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
        super
      end
      
      # returns a new instance of the defined gateway class, using the provided gateway_user and gateway_password
      def gateway
        self.class.gateway_class.new( :login => self.class.gateway_user, :password => self.class.gateway_password )
      end
      
      # inits a new credit card (using ActiveMerchant) and assigns it to current payment object
      def set_credit_card=(fields)
        #self.credit_card = CreditCard.new( fields )
        fields.update( :type => fields.delete(:brand) ) if fields[:brand]
        self.credit_card = ActiveMerchant::Billing::CreditCard.new( fields )
        self.data = { :number => self.credit_card.display_number,
          :first_name => self.credit_card.first_name,
          :last_name => self.credit_card.last_name }
      end
      
      
      # authorize amount and credit_card at payment gateway
      # wrapper for the actual +authorize+ method of a ActiveMerchant gateway.
      # processes the 'authorize' action on the gateway using the +transactions.process+ method
      def authorize( amount = nil, options = {} )
        self.amount = amount || self.order.total_price
        #self.credit_card.decrypt_number
        
        transactions.process( :action => :authorize, :amount => amount_in_cents ) do |gw|
          gw.authorize( amount_in_cents, self.credit_card, options )
        end
        
      end
      
      
      # capture amount from authorization
      # wrapper for the actual +capture+ method of a ActiveMerchant gateway.
      # processes the 'capture' action on the gateway using the +transactions.process+ method
      def capture( amount, authorization, options = {} )
        self.amount = amount || self.order.total_price
        
        transactions.process( :action => :capture, :amount => amount ) do |gw|
          gw.capture( amount_in_cents, authorization, options )
        end
        
      end
      
      
      # purchase amount from credit_card
      # wrapper for the actual +purchase+ method of a ActiveMerchant gateway.
      # processes the 'purchase' action on the gateway using the +transactions.process+ method
      def purchase( amount = nil, options = {} )
        self.amount = amount || self.order.total_price

        process :purchase, amount_in_cents, self.credit_card, options
      end
      

      
      
      
      private

      def process action, amount, credit_card,options #:nodoc:
        transactions.process( :action => action, :amount => amount ) do |gw|
          gw.__send__( action, amount, credit_card, options )
        end
      end
      

      # validate the credit-card
      def validate
        if credit_card
          errors.add( :credit_card, "not valid" ) unless credit_card.valid?
        end
      end

    end
      
      
  
    # States for the Payment Object
    module States
      
      # Payment is authorized by payment-gateway
      module PaymentAuthorized
        include Opensteam::StateLogic::Mod
      end
      
      # payment is captured on payment-gateway
      module PaymentCaptured
        include Opensteam::StateLogic::Mod
      end
      
      # payment was declined on payment-gateway
      module PaymentDeclined
        include Opensteam::StateLogic::Mod
      end
      
      # payment failed on payment gateway
      module PaymentFailed
        include Opensteam::StateLogic::Mod
      end
      
    end

  
  end
  

end