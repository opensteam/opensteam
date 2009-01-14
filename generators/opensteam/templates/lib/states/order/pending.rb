module Opensteam::Sales::OrderBase::States::Pending
  include Opensteam::StateLogic::Mod


  include ActionController::UrlWriter  
  include ActionView::Helpers::UrlHelper  
  include ActionController::UrlWriter  
  
  
  def view_link_to_create_shipment
    { :controller => "admin/sales/shipments", :action => 'new', :order_id => self.id }
  end
  
  
  def view_link_to_create_invoice
    { :controller => "admin/sales/invoices", :action => 'new', :order_id => self.id }
  end
  
end