class CreateQuickSteams < ActiveRecord::Migration
  def self.up
    create_table :quick_steams do |t|
      t.string :name
      t.string :path
      t.integer :position
            
      t.references :user

      t.timestamps
    end
  end

  def self.down
    drop_table :quick_steams
  end
end
