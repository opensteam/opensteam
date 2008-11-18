class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders, :force => true do |t|

      t.references :customer
      t.references :payment_type
      t.references :shipping_address
      t.references :payment_address
      
      t.string :state
      
      t.integer :workflow_id
      
      t.text :description
      
      t.float :total_netto_price, :default => 0.0, :null => false, :limit => 10
      t.float :total_price, :default => 0.0, :null => false, :limit => 10
      t.float :total_tax, :default => 0.0, :null => false, :limit => 10
      
      t.timestamps
      
    end
  end

  def self.down
    drop_table :orders
  end
end
