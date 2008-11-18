class CreatePayments < ActiveRecord::Migration
  def self.up
    create_table :payments do |t|
      t.references :order
      t.decimal :amount, :precision => 8, :scale => 2, :default => 0.0
      
      t.string :description
      t.string :message
      t.string :data
      t.string :state
      t.string :type
      
      t.boolean :test

      t.timestamps
    end
  end

  def self.down
    drop_table :payments
  end
end
