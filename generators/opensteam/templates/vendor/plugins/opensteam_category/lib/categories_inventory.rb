class CategoriesInventory < ActiveRecord::Base
  belongs_to :inventory, :class_name => "Opensteam::Models::Inventory"
  belongs_to :category
end
