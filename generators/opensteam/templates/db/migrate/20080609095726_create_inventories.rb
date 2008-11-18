class CreateInventories < ActiveRecord::Migration
  def self.up
    create_table :inventories do |t|
      t.text :description
      t.string :version
      t.string :shipping_rate_group
      t.float :price, :default => 0.0, :null => false, :limit => 10
      t.integer :storage, :default => 0
      t.integer :active, :default => 0
      t.integer :back_ordered
      
      t.references :tax_group
      t.references :product, :polymorphic => true
      
      t.timestamps

    end
  end

  def self.down
    drop_table :inventories
  end
end
