require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Order do
  
  fixtures :addresses, :users, :inventories
  Address = Opensteam::UserBase::Address
  
  before(:each) do
    
    @payment_address  = addresses( :address_00001 )
    @shipping_address = addresses( :address_00002 )
    @user = users( :quentin )
    
    
    @new_order = Order.new do |o|
      o.customer = @user
      o.payment_type = "bogus"
      o.shipping_type = "Post"
      o.real_shipping_address = @shipping_address
      o.real_payment_address  = @payment_address
    end
    
    @cart = Cart.create
    @cart.push( inventories( :inventory_00042 ) )
    
  end
  
  it "should instantiate a new order" do
    @new_order.should_not be_nil
    @new_order.items.should eql( [] )
  end
  
  it "should associate addresses and customer" do
    @new_order.save.should be_true
    @new_order.reload
    @new_order.customer.should eql( @user )
    @new_order.shipping_address.should eql( @shipping_address )
    @new_order.payment_address.should eql( @payment_address )
  end
  
  
  it "should move items from cart to order" do
    @new_order.save.should be_true
    
    @cart.items.each do |i|
      i.container = @new_order
      i.save
    end
    
    @cart.reload.items.should be_empty
    @new_order.save.should be_true
    
    @new_order.reload
    @new_order.items.should_not be_empty
    
  end
  
  


end

__END__

