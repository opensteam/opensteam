class CreateInventories < ActiveRecord::Migration
  def self.up
    create_table :inventories do |t|
      t.text :description
      t.text :comment
      
      t.string :version
      t.string :shipping_rate_group
      
      
      t.references :product
      t.references :tax_group
      
      t.decimal :price, :default => 0.0, :null => false, :limit => 10
      
      t.integer :storage
      
      t.boolean :active
      t.boolean :back_ordered
      
      t.timestamps
    end
	
	
	create_table :inventories_properties do |t|
      t.references :property
      t.references :inventory

      t.timestamps
    end
  
  end

  def self.down
    drop_table :inventories
	  drop_table :inventories_properties
  end
end

