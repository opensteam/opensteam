class CreateOrderItems < ActiveRecord::Migration
  def self.up
    create_table :order_items do |t|
      t.references :order
      
      t.integer :quantity
      t.references :inventory
      
      
      t.float :price, :default => 0.0, :null => false, :limit => 10
      t.float :tax, :default => 0.0, :null => false, :limit => 10  
      t.float :total_price, :default => 0.0, :null => false, :limit => 10
      
      
      t.integer :quantity
      t.string :itemid
      t.references :inventory

      t.references :shipment
      t.references :invoice

      
      
      

      t.timestamps
    end
  end

  def self.down
    drop_table :order_items
  end
end
