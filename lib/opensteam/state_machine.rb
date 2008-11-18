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


  # StateMachine Module
  #
  # 
  module StateMachine
      

    class EventNotDefined < Opensteam::Config::Errors::OpensteamError
    end

    # raised when the event is not defined for current state
    class EventNotDefinedForCurrentState < Opensteam::Config::Errors::OpensteamError
    end
      
    class EventExecutionError < Opensteam::Config::Errors::OpensteamError
    end
    
    module ClassMethods

     def get_observer ; @@observer ||= [] ; end
        
      def initial_state( state )
        self.initialstate = state
        after_create { |record| record.state = state }
      end

      # observe state-changes -> calls given block after change_state
      def observe( &block )
        observers << Opensteam::StateMachine::Observer.new( self, &block )
      end
      
      # notify association on state-change
      # calls the observers of the association
      def notify(assoc)
        self.observers << Opensteam::StateMachine::Observer.new( self ) do |record|
          record.send( assoc ).class.observers.each { |o| o.exc( record.send( assoc ) ) }
        end
      end
      
    end
    
    
    
    def self.included(base)
      base.extend(ClassMethods)
      base.class_eval do
       include InstanceMethods
        
        # include the history module
        include Opensteam::History
        
        class_inheritable_accessor :observers
        self.observers = []
        
        class_inheritable_accessor :initialstate
        
       
      end


    end
    
    
    class Observer
      attr_accessor :receiver, :code
      
      def initialize( receiver, &block )
        @receiver = receiver
        @code = block
      end
      
      def exc( instance )
        @code.call( instance )
        #        @code.bind( instance ).call
      end
      
      
    end

    
    module ClassMethods
    end
    
    
    module InstanceMethods
      
      
      # returns an array of event-methods for the current state
      # -> the instance_methods of the current +state_module+
      def events ; (s = self.state_module ) ? s.instance_methods : [] ; end

      
      # returns the corresponding module for the current state
      #
      # ex:
      #   o = Order.create
      #   o.state = :pending
      #   o.state_module # => OrderStates::Pending
      #
      def state_module
        return nil unless state
        "#{self.class.to_s.demodulize}States::#{self.state.to_s.classify}".constantize rescue nil
      end
      

      # overrides state-attribute setter
      # calls +change_state+
      def state=(new_state)
        change_state(new_state)
      end

      
      
      
      # fire an event for current state
      # 
      # if self.state is nil, returns false
      # if +event+ is not defined for current state (not an instance method of +state_module+), an error is raised
      # if an error occured during the event, an error-entry is saved into the history
      # calls +change_state+ (return value of the event is used as next-state, if return value is a Symbol or a Module)
      #
      def fire_event(event, *args, &block )
        
        return false unless self.state
        
        add_history( "trying to fire event '#{event}' for state '#{self.state}'" )
        
        return false unless event_scope = self.state_module
        
        unless events.include?( event.to_s )
          add_history( msg = "Error: event '#{event}' not defined for state '#{self.state}'")
          raise EventNotDefined, msg
          return false
        end
        
        begin 
          event_return = event_scope.instance_method( event ).bind( self ).call( *args, &block )
          add_history( "Successfully executed event '#{event}' for state '#{self.state}'" )
        rescue
          add_history("Error: An error occured during event '#{event}' in state '#{self.state}' : '#{$!}'")
        end
        
        unless event_return == false
          self.state = event_return if( event_return.is_a?(Symbol) || event_return.is_a?(Module) )
          return event_return
        end

      end
      
      
      # changes state to +new_state+
      #
      # if current_state is equal +new_state+, return false
      #
      def change_state( new_state )
        if new_state.is_a?( Module )
          new_state = new_state.name
        end
        
        current_state = state
        
        add_history "starting transition from state '#{current_state}' to state '#{new_state}'"
        
        if current_state == new_state
          add_history "transition failed: current_state '#{current_state}' and new_state '#{new_state}' are the same!"
          return false
        end
        
        write_attribute(:state, new_state.to_s)
        ret = save
        
        if ret
          add_history( "Successfull: transition from state '#{current_state}' to state '#{new_state.to_s}'" )
        else
          add_history("Failed: transition from state '#{current_state}' to state '#{new_state.to_s}'")
        end

        @old_state = current_state || ""
        @new_state = new_state || ""
        self.execute_observers
#        self.class.observers.each do |o|
#          o.exc( self )
#        end
        
        ret
  
      end
      
      
      def execute_observers
        self.class.observers.each do |o|
          o.exc( self )
        end
      end

      

      
    end
    
  end
  
end

