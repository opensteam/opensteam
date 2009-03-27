module Opensteam
  module ShipmentExtension
    
    module CartItem
      def self.included(base)
        base.class_eval {
          belongs_to :shipment, :class_name => "Opensteam::Models::Shipment", :counter_cache => "items_count"
        }
      end
    end

  end
end

Opensteam::Container::Item.send( :include, Opensteam::ShipmentExtension::CartItem )
