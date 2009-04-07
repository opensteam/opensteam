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


module Opensteam::Frontend

  # Controller Actions for ShoppingCart( Opensteam::Container::Base, Opensteam::Cart ) manipulation
  module ShoppingCart
		
    def self.included(base) #:nodoc:
      base.extend ClassMethods
      
      base.class_eval do
        include InstanceMethods
        before_filter :get_cart
      end

    end
    
    module ClassMethods #:nodoc:
    end
    
    
    module InstanceMethods
    

      private
      
      # format params[:product] hash (-> rescursive templates...)
      def frmt(h)
        returning(Hash.new) { |hash| h.each_pair { |k,v| k =~ /^products/ ? ( hash[:products] ||= [] ) << frmt(v) : hash[k] = v } }
      end
			
      # returns the id of the current cart object (inside the session)
      def get_cart_id
        session[:cart] ||= Opensteam::Container::Cart.create.id
      end
      
      # returns a cart object
      def get_cart
        @cart = Opensteam::Container::Cart.find( get_cart_id )
      rescue
        session[:cart] = Opensteam::Container::Cart.create.id
        @cart = Opensteam::Container::Cart.find( session[:cart] )
      end
      
		  # destroy cart and create a new one
      def wipe_cart
        session[:cart] = nil
        get_cart
      end
		
      alias :clear_cart :wipe_cart
			
      def redirect_to_index #:nodoc:
        redirect_to opensteam_index_path
      end
			
    end

  end
	
end
