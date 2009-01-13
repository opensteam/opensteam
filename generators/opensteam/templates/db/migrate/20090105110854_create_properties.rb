class CreateProperties < ActiveRecord::Migration
  def self.up
    create_table :properties do |t|
      t.string :type
      t.string :value
      t.string :unit

      t.timestamps
    end
	
	create_table :products_properties do |t|
	  t.references :product
	  t.references :property
	end
	

	
	
  end

  def self.down
    drop_table :properties
    drop_table :products_properties
  end
end
