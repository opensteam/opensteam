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
  module Backend
    module Base


      def self.included(base)
        base.send( :extend, ClassMethods )
      end


      module ClassMethods

        # try to find all subcontroller
        # 
        # Example:
        #   class AdminController < ApplicationController ; end
        #   class Admin::SystemController < AdminController ; end
        #   class Admin::UsersController  < AdminController ; end
        # 
        #   AdminController.subcontroller # => [Admin::SystemController, Admin::UsersController]
        #
        # "AdminController.subcontroller" will check if module Admin is defined.
        # If it is, it will return all constants/classes of this module that inherit from ActionController,
        # thus being a controller class.
        # If module Admin is not defined, it returns an empty array -> no subcontroller found.
        def subcontroller
          self.to_s =~/^(.+)Controller$/
          return [] unless $1
          mod = $1 # module of namespaced controller "Admin::SystemController" => "Admin::System"
          smod = $1.demodulize # "System"
          if( pmod = self.parent ).const_defined?(:"#{smod}")
            return ( mod = mod.constantize ).constants.reject { |r| !( mod.const_get( r ) < ActionController::Base ) }
          end
          return []
        end


        # try to find all subcontroller
        # same as "subcontroller", but using Object.subclasses_of (cycle through ObjectSpace, .. slower)
        def subcontroller2
          Object.subclasses_of( self )
        end


      end
      
    end
  end
end
