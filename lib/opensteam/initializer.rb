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
  
  class Initializer #:nodoc:
    
    class << self ;
      def _logger(args)
        logger = ( defined? RAILS_DEFAULT_LOGGER) ? RAILS_DEFAULT_LOGGER : Logger.new("#{RAILS_ROOT}/log/#{RAILS_ENV}.log")
        logger.info "** [openSteam] #{args}"
      end
    
    
      def run( command = :process, config = Configuration.new )
        yield config if block_given?
    
        init = new config
        init.__send__( command )
      end
      
      
      def require_opensteam_after_initialize
        require 'opensteam/user_base' ## AuthenticatedMethods include !!!
        
        require 'opensteam/helpers/config_table_helper'

        _logger "loaded!"
      end


      def add_controller_paths c
        c.controller_paths.push(
          "#{RAILS_ROOT}/app/controllers/admin/",
          "#{RAILS_ROOT}/app/controllers/admin/system",
          "#{RAILS_ROOT}/app/controllers/admin/catalog",
          "#{RAILS_ROOT}/app/controllers/admin/config"
        )
      end

      def load_controller
        ActionController::Routing.controller_paths.each do |dir|
          Dir[ File.join( dir, "*_controller.rb" ) ].each { |file| load( file ) }
        end
      end
    
    end
    

    def initialize( c )
      @config = c
    end


    def _logger(args) ; self.class._logger( args ) ; end

    
    def process
      require 'opensteam/version'
      _logger"v#{Opensteam::VERSION::STRING} loading .."      
      
      require_libs
      
      
      # extend ActiveRecord with the "opensteam" method
      ActiveRecord::Base.send(:include, Opensteam::Base::Extension )

      Rails::Initializer.class_eval do
        def after_initialize_with_opensteam_initialize
          after_initialize_without_opensteam_initialize
          Opensteam::Initializer.require_opensteam_after_initialize
         # Opensteam::Initializer.add_controller_paths( configuration )
        end
        alias_method_chain :after_initialize, :opensteam_initialize
      end
      
    end
    
    
    def require_libs #:nodoc:
      require 'opensteam/version'
      require 'opensteam/config'
      require 'opensteam/system'
      require 'opensteam/finder'
      require 'opensteam/product_base'
      require 'opensteam/property_base'
      require 'opensteam/base'
      require 'opensteam/history'
      require 'opensteam/state_machine'
      require 'opensteam/shipment_base'
      require 'opensteam/invoice_base'
      require 'opensteam/container'
      require 'opensteam/user_base'
      require 'opensteam/system'
      require 'opensteam/helpers/grid'
      
      require 'opensteam/security'
      require 'opensteam/payment'

      require 'opensteam/inventory_base'
      require 'opensteam/order_base'
            
      require 'opensteam/state_logic'
      require 'opensteam/extension_base'
      require 'opensteam/models'

      require 'opensteam/backend/base'
      
      # require all payment types
      Dir.glob( File.join( File.dirname(__FILE__), "payment", "*.rb" ) ) { |f| 
        require f
      }
      

      require 'opensteam/shopping_cart'
      #    require 'opensteam/cart_base'
      require 'opensteam/checkout'
      require 'opensteam/inventory_base'
      

      

      #      require 'opensteam/order_container'
   
      #   require 'opensteam/tax'
    
      require 'opensteam/money'
    
    end
    
  
  end
  
  
  
  class Configuration #:nodoc:


    
    def say_something
    
      puts "....."
    
    end
  end
  
  
  
  
  
end


