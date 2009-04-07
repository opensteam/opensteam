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
  
  
  # Used to track dynamic constants defined by Opensteam
  # 
  # In order to give a programmer the possibility to implement his own product/property/order/etc model
  # we have to get hold of the Model-Name, to make association-definitions (in the opensteam-library) possible.
  #
  # For this we dynamically define Constants in the Opensteam::Models Module, like Opensteam::Models::Product, as an alias
  # for the actual Model-Constant-Name.
  # Since rails automatically removes all model-constants (names) from the ObjectSpace after every requests (in development environment)
  # and reloads them if needed (using ActiveSupport::Dependencies.load_missing_constant), we have to make sure that our dynamically assigned constants
  # (Opensteam::Models::Product, etc) references the new loaded model-constants.
  #
  # For this purpose we save all Opensteam::Models Constants in the Dependencies.opensteam_constants variable.
  # Second, we implement an alias_method_chain for the ActiveSupport::Dependencies.load_missing_constant method. Every time it tries to laod a missing
  # constant, we check if the constant was defined from opensteam and reload it. Otherwise we call the original load_missing_constant method.
  #
  # This purpose only makes sense in the development-environment. In production-mode all works fine!
  #
  module Dependencies
    
    # saves all model constants defined by opensteam in a hash
    mattr_accessor :opensteam_constants
    self.opensteam_constants = Hash.new(nil)
    
    
    class << self ;

      # creates a new constant "from_module::fromt_const_name" to +to_const+
      # registers thew new created constant in Opensteam::Dependencies.opensteam_constants and
      # flags it as an autoloaded_constant in ActiveSupport::Dependencies.
      # 
      # if +force+ is true, an existing "from_module::from_const_name" constant will be removed,
      # otherwise an exception is thrown
      #
      def set_constant( from_module, from_const_name, to_const, opts = { :force => false } )
        context = from_module ? from_module.constantize : Object
        from_module ||= ""

        if context.const_defined?( from_const_name.to_sym )
          context.instance_eval { remove_const( from_const_name.to_sym) }
        end
        
        opensteam_constants[ from_module.to_s + from_const_name.to_s ] = to_const.to_s
        ActiveSupport::Dependencies.autoloaded_constants << from_module.to_s + from_const_name.to_s
        context.const_set( from_const_name.to_sym, to_const )
        
      end
      
      # returns the original constant for +c+, as registered in the Opensteam::Dependencies.opensteam_constants Hash
      # If c does not exist (in Opensteam::Dependencies.opensteam_constants ), returns nil
      def get_const_for( c )
        to_const = opensteam_constants[ c ] ?
          to_const.classify.constantize : 
          nil
      end
      
      
      # sets the Opensteam::Models::Product constant to +base+
      def set_product_model( base )
        self.set_constant( "Opensteam::Models", "Product", base )
        set_constant(nil, "Product", base ) unless base.to_s == "Product"
      end
      
      # sets the Opensteam::Models::Property constant to +base+
      def set_property_model( base )
        self.set_constant( "Opensteam::Models", "Property", base )
        set_constant(nil, "Property", base ) unless base.to_s == "Property"
      end
      
      # sets the Opensteam::Models::Inventory constant to +base+
      def set_inventory_model( base )
        self.set_constant( "Opensteam::Models", "Inventory", base )
        set_constant(nil, "Inventory", base ) unless base.to_s == "Inventory"
      end
      
      
      def set_user_model( base )
        self.set_constant("Opensteam::Models", "User", base )
        self.set_constant("Opensteam::UserBase", "User", base )
        set_constant(nil, "User", base ) unless base.to_s == "User"
      end
      
      def set_address_model( base )
        self.set_constant("Opensteam::Models", "Address", base )
        self.set_constant( nil, "Address", base ) unless base.to_s == "Address"
      end
      
      def method_missing( method_name, *args, &block )
        if method_name.to_s =~ /^set\_(.+)\_model$/
        model_name = $1.classify
          self.set_constant("Opensteam::Models", model_name, args.first )
          set_constant(nil, model_name, args.first ) unless args.first.to_s == model_name
        else
          super
        end
      end
      
    end
    
  end
end

 ActiveSupport::Dependencies.class_eval do
   
   class << self ;
     
     # looks for the missing constant in the Opensteam::Dependencies.opensteam_constants hash
     # if found, returns the referenced constant. if not, calls the original ActiveSupport::Dependencies.load_missing_constant method
     def load_missing_constant_with_opensteam_constants( from_mod, const_name )
       from_mod_name = from_mod == Object ? "" : from_mod.to_s
       if real_const_name = Opensteam::Dependencies.opensteam_constants[ from_mod_name.to_s + const_name.to_s ]
         real_const_name.constantize
       else
         load_missing_constant_without_opensteam_constants( from_mod, const_name )
       end
     end
   
   #  alias_method_chain :load_missing_constant, :opensteam_constants
   end
 
 end

