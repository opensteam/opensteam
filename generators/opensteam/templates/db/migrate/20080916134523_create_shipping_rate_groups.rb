 class CreateShippingRateGroups < ActiveRecord::Migration
  def self.up
    create_table :shipping_rate_groups do |t|
      t.string :name

      t.decimal :master_rate

      t.boolean :active
      t.boolean :shipping_disabled

      t.timestamps
    end
  end

  def self.down
    drop_table :shipping_rate_groups
  end
end
