__END__

if defined? RAILS_ROOT
  Dir.glob("#{RAILS_ROOT}/lib/states/**/*.rb").collect { |f|
    require f
  }
end

OrderStates = Opensteam::Sales::OrderBase::States
InvoiceStates = Opensteam::Sales::InvoiceBase::States
ShipmentStates = Opensteam::Sales::ShipmentBase::States

if defined? Opensteam::Models::Order
  Opensteam::Models::Order.class_eval do
    include OrderStates::Finished
    include OrderStates::Pending
    include OrderStates::Processing

    named_scope :open, :conditions => ["orders.state is not ?", :finished]

    initial_state :created

    observe do |record|
      if record.shipments.all_finished? && record.items.all_shipped? && record.payments.all_captured?
        record.state = :finished unless record.state.to_sym == :finished
      end

    end

  end
end



# States for Opensteam::Models::Shipment
if defined? Opensteam::Models::Shipment
  Opensteam::Models::Shipment.class_eval do
    include ShipmentStates::Pending
    include ShipmentStates::Finished

    initial_state :pending

    observe do |record|
      notify :order
    end

  end
end

Opensteam::Payment::CreditCardPayment.class_eval do
  include Opensteam::Payment::States::PaymentAuthorized
  include Opensteam::Payment::States::PaymentDeclined
  include Opensteam::Payment::States::PaymentFailed
  include Opensteam::Payment::States::PaymentCaptured
  
  
  initial_state :payment_pending
  
  observe do |record|
    notify :order if record.order
  end

end