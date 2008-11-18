class CreateInventoriesProperties < ActiveRecord::Migration
  def self.up
    create_table :inventories_properties do |t|
      t.references :inventory
      t.references :property, :polymorphic => true

      t.timestamps
    end
  end

  def self.down
    drop_table :inventories_properties
  end
end
