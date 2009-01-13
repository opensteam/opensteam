class CreateCategoriesInventories < ActiveRecord::Migration
  def self.up
    create_table :categories_products do |t|
      t.references :product
      t.references :category
      
      t.timestamps
            
    end
  end
    
  def self.down
    drop_table :categories_products
  end
end
