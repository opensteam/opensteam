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

=begin rdoc
Base Module for openSteam Products and Properties.

- Helper for ProductBase and PropertyBase
- ActiveRecord Extension ( Opensteam::Base::Extension::ActsOpensteam)
- Abstract ProductBase class for ObjectOriented Design
- Base Class for Opensteam Properties (using STI)


=end
  module Base

    # DEPRECATED ! using named_scope noow
    # Extension for the Product-Inventory association
    module ExistByPropertiesExtension #:nodoc:
      
      # checks if an Inventory-Objects exists, which is associated with the given properties
      def exist_by_properties?( p )
        collect(&:properties).collect(&:sort).include?( p.kind_of?( Array ) ? p.sort : p )
      end
    end
    
    
    # Extension for the Product-Properties association
    module PropertiesExtension
      def push( prop ) proxy_owner.send( :add_properties, Array(prop).flatten ) ; end 
      alias :<< :push
      def delete( prop ) proxy_owner.send( :del_properties, Array(prop).flatten ) ; end
      def clear ; proxy_owner.send( :clear_properties ) ; end
    end
    

    
    
=begin rdoc
Helper Module for Opensteam Products and Properties

Defines methods to determine whether an object is a property or a product.
Included both in ProductBase and PropertyBase
( used for security reasons )
=end
    module Helper
      
      def self.included(base) #:nodoc:
        base.extend(ClassMethods)
        class << base ; attr_reader :opensteam_type ; end  
      end

      # check if instance is a Opensteam Property (Opensteam::PropertyBase)
      def is_property?() self.class.is_property? ; end

      # check if instance is a Opensteam Product (Opensteam::ProductBase)
      def is_product?() self.class.is_product? ; end

      
      
      module ClassMethods

        # check if class is a Opensteam::PropertyBase class
        def is_property?() self.ancestors.include? Opensteam::Base::PropertyBase ; end

        # check if class is a Opensteam::ProductBase class,
        # or if Opensteam::ProductBase is included in this class
        def is_product?() ( self.opensteam_type || self.superclass.opensteam_type ) == :product ; end
      end
      
    end

    
    module Extension #:nodoc:
      
      def self.included(base) #:nodoc:
        base.extend ActsOpensteam
      end
      
      require 'opensteam/product_base'
      require 'opensteam/property_base'
      
      # Extend ActiveRecord::Base with the opensteam method
      module ActsOpensteam


        # opensteam method
        # used to include Opensteam::ProductBase Module into the class.
        # injects product-specific instance and class methods into the class.
        #
        #   class ProductABC < ActiveRecord::Base
        #     opensteam :product
        #   end
        #
        def opensteam(arg, *opt)
          Opensteam._log "including #{arg.to_s.humanize} Module in #{self.to_s} Model"
          
          if arg == :product
            @opensteam_type = arg
            class_eval { include Opensteam::ProductBase }
          else
            Opensteam._log "opensteam-method #{arg.to_s} not suppored, in #{self.to_s}"
          end

        end
      
      end
    
    
    end
    
   
    
    # Abstract ProductBase Class
    #
    # Used for Object Oriented Design
    #
    #   class ProductABC < Opensteam::Base::ProductBase
    #   end
    #
    # Product classes can inherit from this class, to get all the Opensteam::ProductBase methods
    # and act as a Opensteam Product
    #
    class ProductBase < ActiveRecord::Base
      self.abstract_class = true
      include Opensteam::ProductBase
      @opensteam_type = :product
      class << self ; attr_reader :opensteam_type ; end 
    end
    
    

    # Base class for Opensteam Properties
    # currently using STI
    #
    # TODO: movie this to Opensteam::Models
    #
    class PropertyBase < ActiveRecord::Base
   #   include Opensteam::PropertyBase
    end
    
    
 
  end
	
end
