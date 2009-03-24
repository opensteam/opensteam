class Product < ActiveRecord::Base
  include Opensteam::Product::Logic
  
  validates_presence_of :name
  
end
