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
    

    class DirectDebitPayment < Base #:nodoc:
      self.display_name = "DirectDebit Payment"
      self.payment_id = :direct_debit
      
      self.observers =  []
      
      def gateway
        nil
      end
      
      
      # authorize amount and credit_card at payment gateway
      def authorize( amount = nil, options = {} )
      end
      
      
      # capture amount from authorization
      def capture( amount, authorization, options = {} )
      end
      
      
      # purchase amount from credit_card
      def purchase( amount = nil, options = {} )
      end
      
    end
    
  end
  
  
  
  
end