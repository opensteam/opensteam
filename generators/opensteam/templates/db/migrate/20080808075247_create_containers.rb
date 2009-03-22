class CreateContainers < ActiveRecord::Migration
  def self.up
    create_table :containers do |t|
      t.string :type

      t.float :total_netto_price, :default => 0.0, :null => false, :limit => 10
      t.float :total_price, :default => 0.0, :null => false, :limit => 10
      t.float :total_tax, :default => 0.0, :null => false, :limit => 10

      t.references :user
      
      t.references :shipping_address
      t.references :payment_address
      
      t.string :state
      t.integer :workflow_id
      t.string :payment_type
      t.integer :items_count, :default => 0, :null => false
      t.string :shipping_type
      t.decimal :shipping_rate, :scale => 2, :precision => 8
      t.text :description
      
      t.timestamps
    end
  end

  def self.down
    drop_table :containers
  end
end
