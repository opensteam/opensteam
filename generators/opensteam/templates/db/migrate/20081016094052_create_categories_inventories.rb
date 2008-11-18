class CreateCategoriesInventories < ActiveRecord::Migration
  def self.up
    create_table :categories_inventories do |t|
      t.references :inventory
      t.references :category
      
      t.timestamps
            
    end
  end
    
  def self.down
    drop_table :categories_inventories
  end
end
