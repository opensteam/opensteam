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

require 'opensteam/shopping_cart'

module Opensteam
	
  
  
=begin rdoc
  Checkout Module

  Defines methods to create a simple checkout-flow

  Currently only used to define a :start action and a :finish action.
  The rest of the checkout-process (the intermediate steps) are handled by the controller-actions (steps)
  itself (like redirecting, errorhandling, etc)

  TODO:
  Implement an actual Checkout-Workflow Generator, with ErrorHandling etc

=end
  
  module Checkout
	
    
    def self.included(base) #:nodoc:
      base.extend(ClassMethods)
      base.class_eval do
        include InstanceMethods
        before_filter :current_step
      end
    end
    
    module ClassMethods #:nodoc:
      
    end

    
    module InstanceMethods
      

      # save the current-action name in the sessions
      def current_step
        session[:current_action] = self.action_name
      end
			

      # method to finish the checkout-process and redirect_to the action
      # specified by :finish
      def endstep
        redirect_to_step(:finish)
      end
			
      # method to create a checkout flow inside a checkout controller:
      #
      #   create_checkout_flow do |c|
      #     c.on :start, :intro
      #     c.on :finish, :controller => "webshop", :action => "index"
      #   end
      #
      def create_checkout_flow( target = self )
        yield target if block_given?
      end
			
			
      # start the checkout process and redirect_to the action
      # specified by :start
      def invoke
        redirect_to_step(:start)
      end

      
      # define a flow step
      #   on :start, :intro
      #   on :finish, :controller => "webshop", :action => "index"
      #
      def on(sym, hash)
        steps.store( sym, hash )
      end
			
      private

      # redirect to a controller action defined my +sym+
      def redirect_to_step(sym)
      	if steps.fetch(sym).kind_of?(Hash)
          redirect_to steps.fetch(sym)
          return
      	end
      	
      	redirect_to :action => steps.fetch(sym)
      end

      # returns the +_step+ hash
      def steps
        @_steps ||= {}
      end
			
    end
		
  end
	
end