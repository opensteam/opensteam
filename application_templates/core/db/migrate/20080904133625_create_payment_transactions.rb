class CreatePaymentTransactions < ActiveRecord::Migration
  def self.up
    create_table :payment_transactions do |t|
      t.references :payment
      
      t.boolean :success
      t.boolean :test
      
      t.string :message
      t.string :reference
      t.string :action
      
      t.integer :amount
      
      t.text :params

      t.timestamps
    end
  end

  def self.down
    drop_table :payment_transactions
  end
end
