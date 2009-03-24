class CreateZones < ActiveRecord::Migration
  def self.up
    create_table :zones do |t|
      t.string :country_name, :null => false
      t.integer :country_numeric
      t.string :country_a2
      t.string :country_a3
      t.string :state
      t.string :postal
      t.string :city

      t.timestamps
    end
  end

  def self.down
    drop_table :zones
  end
end
