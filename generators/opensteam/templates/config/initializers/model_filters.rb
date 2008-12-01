require 'opensteam/user_base'


Order.class_eval do
  include Opensteam::System::FilterEntry::Filter
  filter_keys [ :id, :items, :customer, :shipping_address, :payment_address, :state, :created_at, :updated_at ]
end

TaxZone.class_eval do
  include Opensteam::System::FilterEntry::Filter
  filter_keys [ :id, :country, :state, :rate, :created_at, :updated_at ]
end

TaxGroup.class_eval do
  include Opensteam::System::FilterEntry::Filter
  filter_keys [ :id, :name, :created_at, :updated_at ]
end

#Opensteam::UserBase::User.class_eval do
User.class_eval do
  include Opensteam::System::FilterEntry::Filter
  filter_keys [ :id, :profile, :email, :firstname, :lastname, :orders, :creaetd, :updated_at ]
end

Opensteam::Models::Shipment.class_eval do
  include Opensteam::System::FilterEntry::Filter
  filter_keys [ :id, :order_items, :address, :state, :comment, :created_at, :updated_at ]
end

Opensteam::Models::Invoice.class_eval do
  include Opensteam::System::FilterEntry::Filter
  filter_keys [ :id, :order_items, :address, :state, :comment, :price, :created_at, :updated_at ]
end

Opensteam::Models::Inventory.class_eval do
  include Opensteam::System::FilterEntry::Filter
  filter_keys [ :id, :configuration, :active, :price, :storage, :back_ordered, :tax_group ]
end




  
  

