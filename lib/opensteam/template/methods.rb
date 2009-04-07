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

require 'opensteam/template/runner'

module Opensteam
  
  # Methods for the application-tempalte mechanism in rails 2.3
  module Template
    module Methods

      class << self ;
        def included(base) #:nodoc:
          base.class_eval do 
            attr_accessor :opensteam_template_runner
            public :log, :in_root, :gsub_file, :gem, :run
          end
          
          base.send( :include, InstanceMethods )
        end
      end


      module InstanceMethods
      
        # create a new opensteam application runner object and yields the block
        # used to generate opensteam inside an application-template (rails 2.3)
        def opensteam file_name, args = {}, &block
          o = Opensteam::Template::Runner.new( self )
          o.core( file_name, args )
          o.instance_eval(&block)
          o.write_opensteam_initializer
        end
      end
    end
  end
end


Rails::TemplateRunner.send( :include, Opensteam::Template::Methods )