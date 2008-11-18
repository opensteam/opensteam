
module Mailer
  class UserMailer < ActionMailer::Base

    def signup_notification(user)
      setup_email(user)
      @subject    += 'Please activate your new account'
  
      @body[:url]  = "http://0.0.0.0:3000/activate/#{user.activation_code}"
  
    end
  
    def activation(user)
      setup_email(user)
      @subject    += 'Your account has been activated!'
      @body[:url]  = "http://0.0.0.0:3000/webshop"
    end
  
    protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "ADMINEMAIL"
      @subject     = "[YOURSITE] "
      @sent_on     = Time.now
      @body[:user] = user
    end
  end
end
