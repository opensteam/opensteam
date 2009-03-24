
require 'opensteam/template/runner'

module Opensteam
  module Template
    module Methods

      class << self ;
        def included(base)
          base.class_eval do 
            attr_accessor :opensteam_template_runner
            public :log, :in_root, :gsub_file, :gem, :run
          end
          
          base.send( :include, InstanceMethods )
        end
      end


      module InstanceMethods
      
        def opensteam &block
          o = Opensteam::Template::Runner.new( self )
          o.instance_eval(&block)
          o.write_opensteam_initializer
        end
      end
    end
  end
end


Rails::TemplateRunner.send( :include, Opensteam::Template::Methods )