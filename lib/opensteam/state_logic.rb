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
  
  module StateLogic


    # StateLogic Module
    # included in State Modules
    module Mod

      @@states = []
      mattr_accessor :states

      def self.included(base)
        @@states << base
        base.extend(ClassMethods) if base.is_a?(Module)
        
      end

      module ClassMethods
        
        def name ; self.to_s.demodulize.underscore.to_sym ; end
#        def name ; self.to_s.demodulize.downcase.to_sym ; end

        def respond_to?( method )
          self.protected_instance_methods.include?( method )
        end

        def state_module? ; true ; end
        
        
        
        
        # included method
        # called when the state-module is included into the receiver-class (like Order, Shipment, Invoice)
        #
        # for each instance-method of the state-module, it creates an alias (in the receiver-klass) and delegates it
        # to the corresponding state-module (based on receiver.state -> StatePattern) through the fire_event method.
        def included(receiver)
          self.instance_methods(false).each do |m|
            
            receiver.class_eval do
              define_method(m) { |*args| fire_event( m, *args ) }
            end
            
          end
          
          # state_name = self.to_s.demodulize.downcase
          state_name = self.to_s.demodulize.underscore
          receiver.class_eval do
            define_method("#{state_name}?") { self.state == state_name }
            named_scope state_name, :conditions => ["#{self.table_name}.state = ?", state_name ]
            
            class << self ;
              def available_states
                self.included_modules.select { |s| 
                  s.ancestors.include?( Opensteam::StateLogic::Mod ) }.reject { |s| 
                  s == Opensteam::StateLogic::Mod }
              end
            end
          end
        
        end

      end

    end



    
    require 'observer'
    
  
  end
  

end


