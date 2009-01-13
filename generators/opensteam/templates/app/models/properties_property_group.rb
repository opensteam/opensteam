class PropertiesPropertyGroup < ActiveRecord::Base
  belongs_to :property_group
  belongs_to :property
end
