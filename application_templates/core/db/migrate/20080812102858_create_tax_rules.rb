class CreateTaxRules < ActiveRecord::Migration
  def self.up
    create_table :tax_rules do |t|
      t.references :tax_zone
      t.references :customer_tax_group
      t.references :product_tax_group

      t.timestamps
    end
  end

  def self.down
    drop_table :tax_rules
  end
end
