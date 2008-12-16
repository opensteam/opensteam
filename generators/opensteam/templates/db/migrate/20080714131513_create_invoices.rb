class CreateInvoices < ActiveRecord::Migration
  def self.up
    create_table :invoices do |t|
      t.float :price, :limit => 10, :default => 0.0, :null => false
      t.float :discount, :limit => 10, :default => 0.0, :null => false
      t.text :comment

      t.references :customer
      t.references :order
      t.references :address
      
      t.string :state
      t.integer :items_count, :default => 0, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :invoices
  end
end
