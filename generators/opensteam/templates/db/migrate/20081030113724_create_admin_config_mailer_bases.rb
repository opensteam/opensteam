class CreateAdminConfigMailerBases < ActiveRecord::Migration
  def self.up
    create_table :config_mails do |t|
      t.string :mailer_method
      t.string :mailer_class

      t.boolean :active

      t.datetime :send_on

      t.integer :messages_sent

      t.timestamps
    end
  end

  def self.down
    drop_table :config_mails
  end
end
