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
  
  
  # Config Module for Opensteam
  #
  #
  module Config
    
    
    class << self ;
      
      def [](name) #:nodoc:
        Base[ name ]
      end
      
      def []=(key,val) #:nodoc:
        Base[ key ] = val
      end
      
      
    end
    
    
    # Model for Opensteam Configuration
    #
    # simple key-value configuration model#
    # used to store information like DEFUALT_COUNTRY, DEFAULT_TAX_GROUP, DEFUALT_SHUIPPING_RATE, etc
    #
    class Base < ActiveRecord::Base #:nodoc:
      self.table_name = "configurations"
    
      class << self ;

        # hash-like setter to the key-value pairs inside the configuration table
        def []=( k,v )
          if c = find_by_key( k.to_s.downcase )
            c.update_attribute( :value, v )
          else
            c = create( :key => k.to_s.downcase, :value => v )
          end
          c
        end

        # hash-like getter for the key-value pairs inside the configuration table
        def [](name)
          find_by_key( name.to_s.downcase ).value
        rescue
          ""
        end
      end
    
    end
    
    
    module Errors
      # generic error class
      class OpensteamError < StandardError
      end
  
      # NotAProduct Error
      # raised if Object is not a product (make "constantize" secure..)
      class NotAProduct < OpensteamError
      end
  
      # NotAProperty
      # raised if Object is not a property
      class NotAProperty < OpensteamError
      end
  
    end
    
  end
  

  
  # UUID Helper
  # used to generate uuids for primary keys
  # DEPRECATED!
  # TODO: fix UUID Helper!!
  #
  module UUIDHelper
    require 'rubygems'
    require 'uuidtools'
    
    def self.included(base)
      base.class_eval do
        before_create :set_uuid
        private :set_uuid
      end
    end
    
    def set_uuid
      self.id = UUID.random_create.to_s
    end
    
  end
  
end


