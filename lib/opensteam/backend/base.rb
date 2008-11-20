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
        # Admin::SystemController.subcontroller will check if module Admin::System is defined.
        # If it is, it will return all constants of this module, that are inherited from ActionController::Base
        #
        # given Admin::SystemController:
        # - smod = System
        # - pmod = Admin
        # - mod = Admin::System
        def subcontroller
          self.to_s =~/^(.+)Controller$/
          return [] unless $1
          mod = $1
          smod = $1.demodulize
          if( pmod = self.parent ).const_defined?(:"#{smod}")
            return ( mod = mod.constantize ).constants.reject { |r| !( mod.const_get( r ) < ActionController::Base ) }
          end
          return []
        end


        # try to find all subcontroller
        #
        # using Object.subclasses_of (cycle through ObjectSpace)
        def subcontroller2
          Object.subclasses_of( self )
        end


      end
      
    end
  end
end
