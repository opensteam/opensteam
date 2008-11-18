class CreateTaxGroups < ActiveRecord::Migration
  def self.up
    create_table :tax_groups do |t|
      t.string :name
      t.string :type

      t.timestamps
    end
  end

  def self.down
    drop_table :tax_groups
  end
end
