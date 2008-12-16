require 'opensteam/user_base'


Order.class_eval do
  include Opensteam::Helpers::Grid

  configure_grid(
    :id => :id,
    :order_items => :items_count,
    :customer => { :customer => [:email,:login] },
    :shipping_address => { :shipping_address => [ :firstname, :lastname, :street, :postal, :city, :country ] },
    :payment_address => {  :payment_address => [ :firstname, :lastname, :street, :postal, :city, :country ] },
    :state => :state,
    :created_at => :created_at,
    :updated_at => :updated_at,
    :editor_url => :editor_url
  )
  
  def editor_url ; "orders/#{self.id}" ; end
end


Opensteam::Models::Invoice.class_eval do
  include Opensteam::Helpers::Grid
  configure_grid(
    :id => :id,
    :address => { :address => [ :firstname, :lastname, :street, :postal, :city, :country ] },
    :state => :state,
    :price => :price,
    :created_at => :created_at,
    :updated_at => :updated_at,
    :editor_url => :editor_url
  )
  def editor_url ; "invoices/#{self.id}" ; end
end

Opensteam::Models::Shipment.class_eval do
  include Opensteam::Helpers::Grid
  configure_grid(
    :id => :id,
    :address => { :address => [ :firstname, :lastname, :street, :postal, :city, :country ] },
    :state => :state,
    :rate => :shipping_rate,
    :comment => :comment,
    :created_at => :created_at,
    :updated_at => :updated_at,
    :editor_url => :editor_url
  )
  def editor_url ; "shipments/#{self.id}" ; end
end


TaxZone.class_eval do
  include Opensteam::Helpers::Grid
  configure_grid(
    :id => :id,
    :country => :country,
    :state => :state,
    :rate => :rate,
    :created_at => :created_at,
    :updated_at => :updated_at,
    :editor_url => :editor_url,
    :delete_url => :editor_url
  )
end

TaxGroup.class_eval do
  include Opensteam::Helpers::Grid
  configure_grid(
    :id => :id,
    :name => :name,
    :created_at => :created_at,
    :updated_at => :updated_at
  )
end

User.class_eval do
  include Opensteam::Helpers::Grid
  configure_grid(
    :id => :id,
    :name => [ :firstname, :lastname ],
    :roles => { :user_roles => :name },
    :email => :email,
    :activated_at => :activated_at,
    :deleted_at => :deleted_at,
    :state => :state,
    :created_at => :created_at,
    :updated_at => :updated_at
  )
end

Opensteam::Models::Inventory.class_eval do
  include Opensteam::Helpers::Grid
  configure_grid(
    :id => :id,
    :storage => :storage,
    :price => :price,
    :configuration => { :properties => :name },
    :active => :active,
    :back_ordered => :back_ordered,
    :tax_group => { :tax_group => :name }
  )
  
end




  
  

