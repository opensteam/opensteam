class CreateSearches < ActiveRecord::Migration
  def self.up
    create_table :searches do |t|
      t.string :keywords
      t.string :properties
      t.float :minimum_price
      t.float :maximum_price
      t.integer :minimum_storage
      t.integer :maximum_storage
      
      t.string :kind
      t.references :customer
      t.timestamps
    end
  end
  
  def self.down
    drop_table :searches
  end
end
