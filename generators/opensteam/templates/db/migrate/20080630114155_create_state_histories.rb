class CreateStateHistories < ActiveRecord::Migration
  def self.up
    create_table :histories do |t|
      t.references :receiver, :polymorphic => true
      t.text :message
    
      t.timestamps
    end
  end

  def self.down
    drop_table :histories
  end
end
