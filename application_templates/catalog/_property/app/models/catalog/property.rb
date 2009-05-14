class Property < ActiveRecord::Base
  include Opensteam::Property::Logic

  validates_uniqueness_of :value, :scope => :type

end
