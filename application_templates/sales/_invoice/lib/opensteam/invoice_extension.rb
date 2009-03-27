module Opensteam
  module InvoiceExtension
    
    module CartItem
      def self.included(base)
        base.class_eval {
          belongs_to :invoice, :class_name => "Opensteam::Models::Invoice", :counter_cache => "items_count"
        }
      end
    end

  end
end

Opensteam::Container::Item.send( :include, Opensteam::InvoiceExtension::CartItem )
