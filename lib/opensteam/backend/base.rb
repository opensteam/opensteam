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

    mattr_accessor :controller_paths
    self.controller_paths = []

    mattr_accessor :loaded_controller
    self.loaded_controller = false


    # load all *_controller.rb files in Opensteam::Backend.controller_paths
    # if controller are not loaded yet and Rails is in development environment
    def self.load_controller( cpath = self.controller_paths)
      return if self.controller_loaded? && RAILS_ENV != "development"
      cpath.each do |dir|
        Dir[ File.join( dir, "*_controller.rb") ].each { |file| puts file ; load(file) }
      end
      self.loaded_controller = true
    end

    # set Opensteam::Backend.loaded_controller to false
    # reloads controller on next request
    def self.reset_controller_load!
      self.loaded_controller = false
    end

    # check if controller are loaded
    def self.controller_loaded?
      self.loaded_controller
    end

    
    module Base


      mattr_accessor :backend_controller
      self.backend_controller = {}

      def self.included(base)
        base.send( :extend, ClassMethods )
        Opensteam::Backend.load_controller
      end



      module ClassMethods

        # save the inherited controller class into Opensteam::Backend::Base.backend_controller hash
        def inherited(sub)
          super
          Opensteam::Backend::Base.backend_controller[ sub.superclass.to_s ] ||= []
          Opensteam::Backend::Base.backend_controller[ sub.superclass.to_s ] << sub.to_s
        end


        # returns the sub_controller specified in Opensteam::Backend::Base
        # Opensteam::Backend::Base.backend_controller is hash containing all backend_controller with superclass
        # 
        # Example:
        #   { AdminController => [ Admin::SystemController ],
        #     Admin::SystemController => [ Admin::System::UsersController ]
        #   }
        #
        def sub_controller
          Opensteam::Backend::Base.backend_controller[ self.to_s ]
        end

        
        # returns the sub_controller_tree as a hash:
        #   AdminController.sub_controller_tree
        #   # => { AdminController => { Admin::SystemController => { Admin::System::UsersController => [] } } }
        #
        # use +method+ to change the hash key:
        #   AdminController.sub_controller_tree :to_s
        #   # => { "AdminController" => { "Admin::SystemController" => { "Admin::System::UsersController" => [] } } }
        #   
        # or:
        #   AdminController.sub_controller_tree :to_s
        #   # => { "admin" => { "admin/system" => { "admin/system/users" => [] } } }
        #
        # use +empty+ to specify what to return if no sub_controller exist, default is []
        #
        def sub_controller_tree method = nil, empty = []
          return empty unless sub_controller
          sub_controller.inject({}) { |r,v| r[ method ? v.send(method) : v ] = v.sub_controller_tree( method ); r }
        end


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
            return ( mod = mod.constantize ).constants.reject { |r|
              !( mod.const_get( r ) < ActionController::Base )
            }.collect { |r| mod.const_get( r ) }
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
