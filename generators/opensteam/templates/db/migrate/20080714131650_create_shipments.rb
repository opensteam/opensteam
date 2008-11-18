class CreateShipments < ActiveRecord::Migration
  def self.up
    create_table :shipments do |t|
      t.text :comment

      t.string :state
      
      t.references :order
      t.references :address
      t.references :customer
      
      t.decimal :shipping_rate, :decimal, :scale => 2, :precision => 8
      
      t.timestamps
    end
  end

  def self.down
    drop_table :shipments
  end
end
