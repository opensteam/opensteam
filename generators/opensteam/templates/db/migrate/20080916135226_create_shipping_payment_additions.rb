class CreateShippingPaymentAdditions < ActiveRecord::Migration
  def self.up
    create_table :shipping_payment_additions do |t|
      t.references :shipping_rate_group
      
      t.decimal :amount, :precision => 8, :scale => 2, :default => 0.0

      t.string :payment_type
      t.string :operator, :default => "+"
      
      t.boolean :fix_value
      
      t.timestamps
    end
  end

  def self.down
    drop_table :shipping_payment_additions
  end
end
