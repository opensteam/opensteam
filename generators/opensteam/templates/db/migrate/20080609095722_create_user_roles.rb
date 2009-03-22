class CreateUserRoles < ActiveRecord::Migration
  def self.up
    create_table "user_roles" do |t|
      t.string :name
    end
    
    # generate the join table
    create_table "user_roles_users", :id => false do |t|
      t.integer "user_role_id", "user_id"
    end
    add_index "user_roles_users", "user_role_id"
    add_index "user_roles_users", "user_id"
  end

  def self.down
    drop_table "user_roles"
    drop_table "user_roles_users"
  end
end