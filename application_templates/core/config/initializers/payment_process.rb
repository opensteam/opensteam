Opensteam::Payment::CreditCardPayment.class_eval do 
  
  self.gateway_class = ActiveMerchant::Billing::BogusGateway
  
  def execute_payment
    authorization = self.authorize
    
    if authorization.success? 
      self.state = :payment_authorized
    else
      self.state = :payment_declined
      return authorization
    end
    
    capt = self.capture( nil, authorization.reference )
    
    if capt.success?
      self.state = :payment_captured
    else
      self.state = :payment_failed
    end
    
    return true
  end
  
  
  
  after_create :execute_payment
  private :execute_payment
  
  
end

