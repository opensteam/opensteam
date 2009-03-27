require_dependency 'shipment'
require_dependency 'invoice'
class Order < Opensteam::Container::Base
  include Opensteam::Sales::OrderBase

  # get orders by given user
  named_scope :by_user, lambda { |user_id| { :include => [:customer ], :conditions => { :user_id => user_id } } }
end