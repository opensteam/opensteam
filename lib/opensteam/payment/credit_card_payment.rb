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

  
  end
  

end