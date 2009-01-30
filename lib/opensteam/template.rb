module Opensteam
  module Template


    def opensteam name, &block
      opensteam_template = Opensteam::Template::Runner.new( name, self )
      opensteam_template.generate
      opensteam_template.instance_eval(&block) if block_given?

    end


    class Runner
      attr_accessor :rails_runner
      attr_accessor :store_name

      def initialize( store_name, template_runner )
        self.rails_runner = template_runner
        self.store_name = store_name
      end

      def generate
        self.rails_runner.generate :opensteam, self.store_name.to_s.classify
      end
      
    end

  end
end

require 'rails_generator/generators/applications/app/template_runner'
module Rails
  class TemplateRunner
    include Opensteam::Template
  end
end