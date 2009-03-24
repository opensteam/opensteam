class CreateContainerItems < ActiveRecord::Migration
  def self.up
    create_table :container_items do |t|
      
      t.references :item, :polymorphic => true
      t.references :container
      
      t.integer :quantity, :default => 1, :null => false
      
      t.float :price, :default => 0.0, :null => false, :limit => 10
      t.float :tax, :default => 0.0, :null => false, :limit => 10  
      t.float :total_price, :default => 0.0, :null => false, :limit => 10
      
      t.references :shipment
      t.references :invoice
      

      t.timestamps
    end
  end

  def self.down
    drop_table :container_items
  end
end
