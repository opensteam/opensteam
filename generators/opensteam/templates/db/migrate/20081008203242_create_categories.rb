class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.string :name
      t.boolean :active
      t.text :description
      
      t.integer :parent_id
      t.integer :rgt_id
      t.integer :lft_id
      
      t.timestamps
    end
  end

  def self.down
    drop_table :categories
  end
end
