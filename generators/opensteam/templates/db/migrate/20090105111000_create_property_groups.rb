class CreatePropertyGroups < ActiveRecord::Migration
  def self.up
    create_table :property_groups do |t|
      t.string :name
      t.string :selector
      t.string :selector_text
	  
      t.text :description

	    t.references :product

      t.timestamps
    end
	
	  create_table :properties_property_groups, :id => false do |t|
	    t.references :property
	    t.references :property_group
    end
    
    add_index :properties_property_groups, :property_id
    add_index :properties_property_groups, :property_group_id
	
  end

  def self.down
    drop_table :property_groups
	  drop_table :properties_property_groups
	end
end
