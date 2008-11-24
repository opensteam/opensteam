require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Mailer::OrderMailer do
  
  fixtures :addresses, :users, :inventories
  Address = Opensteam::UserBase::Address
 
  before(:each) do


    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @payment_address  = addresses( :address_00001 )
    @shipping_address = addresses( :address_00002 )
    @user = users( :quentin )

    @new_order = Order.new do |o| #Opensteam::OrderBase::Order.new do |o|
      o.customer = @user
      o.payment_type = "bogus"
      o.shipping_type = "Post"
      o.real_shipping_address = @shipping_address
      o.real_payment_address  = @payment_address
    end

#    @cart = Cart.create
#    @cart.push( inventories( :inventory_00042 ) )
#
#    @cart.items.each do |i|
#      i.container = @new_order
#      i.save
#    end

    Opensteam::System::Mailer.mailer_class("Mailer::OrderMailer" ).mailer_method("order_confirmation").first.update_attributes( :messages_sent => 0 ) ;
    

  end

  it "should save the order and send confirmation email" do
    ActionMailer::Base.deliveries.size.should == 0
    @new_order.should_not be_nil
    @new_order.save.should be_true
    Opensteam::System::Mailer.activate( Mailer::OrderMailer, :order_confirmation )
    Mailer::OrderMailer.deliver_order_confirmation( @new_order ).class.should == TMail::Mail
    ActionMailer::Base.deliveries.size.should == 1
    Opensteam::System::Mailer.mailer_class("Mailer::OrderMailer" ).mailer_method("order_confirmation").first.messages_sent.should == 1

  end

  it "should save the order and not send confirmation email" do
    ActionMailer::Base.deliveries.size.should == 0
    @new_order.save.should be_true
    Opensteam::System::Mailer.deactivate( Mailer::OrderMailer, :order_confirmation )
    Mailer::OrderMailer.deliver_order_confirmation( @new_order ).should be_nil
    ActionMailer::Base.deliveries.size.should == 0
    Opensteam::System::Mailer.mailer_class("Mailer::OrderMailer" ).mailer_method("order_confirmation").first.messages_sent.should == 0

  end
  


end

__END__

