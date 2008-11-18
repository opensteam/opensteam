class CreateTaxZones < ActiveRecord::Migration
  def self.up
    create_table :tax_zones do |t|
      t.string :country, :null => false
      t.string :state, :default => "*"
      t.string :postal, :default => "*"
      t.float :rate, :default => 0.0, :limit => 10

      t.timestamps
    end
  end

  def self.down
    drop_table :tax_zones
  end
end
