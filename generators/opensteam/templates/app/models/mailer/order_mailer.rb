module Mailer
  class OrderMailer < ActionMailer::Base

    helper :admin, :checkout
    def order_confirmation(order)
      recipients order.customer.email
      from "order@opensteam.net"
      subject "thank you for your order ##{order.id}"
      content_type "text/html"
      body :order => order
    end


    def order_payment_confirmation(order, payment)
      recipients order.customer.email
      from "order@opensteam.net"
      subject "payment confirmation for order ##{order.id}"
      body :order => order, :payment => payment
    end

  
    def order_shipment_confirmation(order, shipment)
      recipients order.customer.email
      from "order@opensteam.net"
      subject "shipment confirmation for order ##{order.id}"
      body :order => order, :shipment => shipment
    end

  
    def order_message(order, message)
      recipients order.customer.email
      from "order@opensteam.net"
      subject "message for order ##{order.id}"
      body :order => order, :message => message
    end
  end
  
end
