class CreateFilterEntries < ActiveRecord::Migration
  def self.up
    create_table :filter_entries do |t|
      t.string :val
      t.string :op
      t.string :key

      t.timestamps
    end
  end

  def self.down
    drop_table :filter_entries
  end
end
