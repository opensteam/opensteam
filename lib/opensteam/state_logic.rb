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
        #
        
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
    
#    
#    class Base < ActiveRecord::Base
#      self.table_name = "states"
#
#
#      def self.state_type ; :state_base ; end
#      def state_type ; self.class.state_type ; end
#      
#      Object.const_set "State", self
#      
#      @@sub_states = []
#      class_inheritable_accessor :sub_states
#      
#
#      def self.inherited(base)
#        ( self.sub_states ||= [] ) << base
#
#      end
#
#
#
#
#      def self.mod ; "#{self.to_s}Module".classify.constantize ; end
#      def mod ; self.class.mod ; end
#
#      def self.state_name
#        self.to_s =~ /^(.+)State$/
#        $1 ? $1.underscore.to_sym : self.to_s.to_sym
#      end
#      
#      def state_name ; self.class.state_name ; end
#      
#      def to_s ; self.state_name ; end
#      
#      
#      def self.events
#        ( ( self.instance_methods(false) - self.generated_methods.to_a ).collect { |x|
#            x =~ /!$/ ? x : nil }.compact.collect(&:to_sym) )
#      end
#      
#      
#      def events ; self.events ; end
#      
#      
#      def self.instance_for_event( sym )
#        "#{sym}State".classify.constantize.create
#      end
#      
#      
#      
#      
#      
#      
#      
#     
#      
#      def self.state(name, &block)
#        klass_name = "#{name}State".classify
#        begin
#          klass = klass_name.constantize
#          raise NameError if klass.superclass != self
#          puts "#{klass} is defined!!"
#        rescue NameError
#          klass = Class.new( self )
#          Object.const_set klass_name, klass
#        end
#        klass.class_eval(&block) if block_given?
#      end
#      
#      
#      def self.event(name, *args, &block)
#        self.class_eval { define_method(name) { block.call } if block_given? }
#        Opensteam::StateMachine.inject_state_queries( self )
#        Opensteam::StateMachine.inject_event_methods( self )
#      end
#      
#      
#      def self.transition_observer(*args, &block)
#        if args.first.is_a?( Hash )
#          from, to = args.first.keys.first, args.first.values.first
#        else
#          from, to = self.state_name, args.first
#        end##
#
#        if block_given?
#          #      Opensteam::StateMachine.transitions[from] ||= {}
#          #      ( Opensteam::StateMachine.transitions[from][to] ||= [] ) << block
#        end
#        
#      end
#      
#    end
#    
#    

  
  end
  

end



#if defined? RAILS_ROOT
#  
#  Dir.glob("#{RAILS_ROOT}/app/states/**/*.rb").collect { |f|
#    puts f
#    require f
#    klass_name = "#{File.basename(f,'.rb')}State".classify
#    begin
#      klass = klass_name.constantize
#    rescue NameError
#      klass = Class.new( Opensteam::StateLogic::Base )
#      Object.const_set klass_name, klass
#    end
#  }
#
#end


## if rails is runniny
#if defined? RAILS_ROOT
#  ## init all states and create event methods for the Order-Instance
#  Dir.glob("#{RAILS_ROOT}/app/models/*_states.rb").collect { |f|
#    require Opensteam::State::Machine.create_event_methods_for_order( File.basename(f, ".rb").classify.constantize )
#  }
#end


