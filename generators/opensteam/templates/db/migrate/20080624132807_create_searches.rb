class CreateSearches < ActiveRecord::Migration
  def self.up
    create_table :searches do |t|
      t.string :keywords
      
      t.float :minimum_price
      t.float :maximum_price
      
      t.float :minimum_storage
      t.float :maximum_storage
      
      t.float :klass
      
      t.references :customer

      t.string :properties
      
      t.timestamps
    end
  end
  
  def self.down
    drop_table :searches
  end
end
