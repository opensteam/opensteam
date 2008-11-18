class CreateAddresses < ActiveRecord::Migration
  def self.up
    create_table :addresses do |t|
      t.references :user
      
      t.string :country
      t.string :state
      t.string :postal
      t.string :city
      t.string :street
      
      t.string :firstname
      t.string :lastname
      

      t.timestamps
    end
  end

  def self.down
    drop_table :addresses
  end
end
