require 'active_record/fixtures'

class InitOpensteamConfig < ActiveRecord::Migration
  def self.up

    # create profile
    UserRole.create( :name => "admin" )
    UserRole.create( :name => "customer" )

    u = User.new(
      :login => 'admin',
      :firstname => 'admin',
      :lastname => 'admin',
      :email => 'admin@host.com',
      :password => 'opensteam',
      :password_confirmation => 'opensteam'
    )

    u.save
    u.register!
    u.user_roles << UserRole.find_by_name('admin')
    u.save
    u.activate!


    # init config
    Opensteam::Config[ :shipping_strategy ] = 'per_order'
    Opensteam::Config[ :shipping_rate_group_default] = 'Default Shipping Rate'
    Opensteam::Config[ :product_shipping_rate_group_default] = 'Default Shipping Rate'
    Opensteam::Config[ :default_country ] = 'Austria'

    # init fixtures
    ENV['FIXTURES'] = "region_shipping_rates,shipping_payment_additions,shipping_rate_groups,tax_groups,tax_rules,tax_zones,zones"
    ENV['FIXTURES'].split(/,/).each do |fixture_file|
      Fixtures.create_fixtures('test/fixtures', File.basename(fixture_file, '.*'))
    end


  end

  def self.down
    [ "admin", "guest" ].each do |profile|
      UserRole.find_by_name( profile ).destroy rescue nil
    end

    User.find_by_login('admin').destroy rescue nil

    Zone.delete_all

  end



end

