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




    # load zones
    Fixtures.create_fixtures('test/fixtures', "zones" )

    # load tax_groups, tax_zones, tax_rules
    [ 'tax_groups', 'tax_zones', 'tax_rules' ].each do |fixture_file|
      Fixtures.create_fixtures( 'text/fixtures', fixture_file )
    end

    # load shipping rate fixtures
    [ 'region_shipping_rates', 'shipping_payment_additions', 'shipping_rate_groups' ].each do |fixture_file|
      Fixtures.create_fixtures( 'text/fixtures', fixture_file )
    end

    # init configuration
    Opensteam::Config[ :shipping_strategy ] = 'per_order'
    Opensteam::Config[ :shipping_rate_group_default] = 'Default Shipping Rate'
    Opensteam::Config[ :product_shipping_rate_group_default] = 'Default Shipping Rate'
    Opensteam::Config[ :default_country ] = 'Austria'




  end

  def self.down
    [ "admin", "guest" ].each do |profile|
      UserRole.find_by_name( profile ).destroy rescue nil
    end

    User.find_by_login('admin').destroy rescue nil

    Zone.delete_all

  end



end

