class CategoriesProduct < ActiveRecord::Base
  belongs_to :product, :class_name => "Opensteam::Models::Product" #, :class_name => "Opensteam::Models::Inventory"
  belongs_to :category
end
