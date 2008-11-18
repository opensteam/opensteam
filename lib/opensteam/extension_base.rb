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
  
  # module to handle Opensteam Extensions
  # (not in use right now)
  module ExtensionBase #:nodoc:
    
    mattr_accessor :extension_path
    @@extension_path = File.join( "#{RAILS_ROOT}", "vendor", "opensteam_extensions")
    
    
    class << self ;
      
      
      def init_extensions( which = :backend )
        return false unless ActiveRecord::Base.connection.tables.include?( "extensions" )
        
        
        path = File.join( extension_path, which.to_s, "**" )
        
        Dir.glob( path ).each do |ext_path|
          ext_name = File.basename( ext_path )
          "Opensteam::ExtensionBase::#{which.to_s.classify}".constantize.find_or_create_by_name( :name => ext_name, :path => path )
        end
      end
      
      
      def verify_extensions( which = :backend )
        return false unless ActiveRecord::Base.connection.tables.include?( "extensions" )
        "Opensteam::ExtensionBase::#{which.to_s.classify}".constantize.find(:all).collect(&:verify_path)
      end
      
    
    
    end
    
      
    
    # Extension-Model
    #
    class Extension < ActiveRecord::Base
      named_scope :active, :conditions => { :active => 1 }
      named_scope :inactive, :conditions => { :active => 0 }
      
      
      
      
      def active? ; active == 0 ? false : true ; end
      
      # activate the extension
      def activate! ; self.update_attribute( :active, 1 ) ; end
      
      # deactivate the extension
      def deactivate! ; self.update_attribute( :active, 0 ) ; end
      
      # verify the extension-path
      # if path doesn't exist, set error and deactivate extension
      # if path exist, delete previous error-message.
      #
      def verify_path
        if File.exists?( self.path )
          self.error = nil
          self.save
        else
          self.error = "Extensions-Path '#{self.path}' not found!"
          self.deactivate!
        end
      end
      
      
      
      
    end

    class Backend < Extension #:nodoc:
    end
    
  end

end