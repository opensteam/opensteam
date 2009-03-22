class CreateConfigurations < ActiveRecord::Migration
  def self.up
    create_table :configurations do |t|
      t.string :key
      t.string :value
      t.string :type

      t.timestamps
    end
  end

  def self.down
    drop_table :configurations
  end
end
