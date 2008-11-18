class UserObserver < ActiveRecord::Observer
  observe :user
  
  def after_create(user)
    puts "*******" * 100
    mail = Opensteam::Mailer::UserMailer.create_signup_notification( user )
    puts mail
    Opensteam::Mailer::UserMailer.deliver( mail )
 #   Opensteam::Mailer::UserMailer.deliver_signup_notification(user)
  end

  def after_save(user)
  puts "++++++" * 100
    mail = Opensteam::Mailer::UserMailer.create_activation( user ) if user.recently_activated?
    puts mail
    Opensteam::Mailer::UserMailer.deliver( mail )
#    Opensteam::Mailer::UserMailer.deliver_activation(user) if user.recently_activated?
  
  end
end