class CreateProperties < ActiveRecord::Migration
  def self.up
    create_table :properties do |t|
      t.string :type
      t.string :value
      t.string :unit
      t.string :presentation_value

      t.timestamps
    end
	
	create_table :products_properties do |t|
	  t.references :product
	  t.references :property
	end
	
	add_index :products_properties, :property_id
  add_index :products_properties, :product_id
  
  

	
	
  end

  def self.down
    
    remove_index :products_properties, :property_id
    remove_index :products_properties, :product_id
    
    drop_table :products_properties
    drop_table :properties

  end
end
