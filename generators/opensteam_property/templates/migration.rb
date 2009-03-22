class <%= migration_name %> < ActiveRecord::Migration

  def self.up
<% for attribute in migration_attributes -%>
    add_column :properties, :<%= attribute.name %>, :<%= attribute.type %>
<% end %>
  end

  def self.down
<% for attribute in migration_attributes -%>
    remove_column :properties, :<%= attribute.name %>
<% end %>
  end
end
## TEMPLATE ##