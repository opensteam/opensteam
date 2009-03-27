class Shipment < ActiveRecord::Base
  include Opensteam::Sales::ShipmentBase
end