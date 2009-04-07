#Inventory = Opensteam::Models::Inventory

Zone = Opensteam::System::Zone

module Prawnto
  module TemplateHandler
    class Base < ActionView::TemplateHandler
      def self.compilable?
        false
      end

      def compile(template)
      end
    end
  end
end





