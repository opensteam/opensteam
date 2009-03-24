class CreateRegionShippingRates < ActiveRecord::Migration
  def self.up
    create_table :region_shipping_rates do |t|
      t.references :zone
      t.references :shipping_rate_group
      
      t.string :shipping_method
      
      t.decimal :rate, :precision => 8, :scale => 2, :default => 0.0

      t.timestamps
    end
  end

  def self.down
    drop_table :region_shipping_rates
  end
end
