## TEMPLATE ##
class OpensteamController < ApplicationController
  layout '<%= file_name %>'
  
  # Shopping Cart manipulation
  include Opensteam::Frontend::ShoppingCart
  
  # authentication
  include Authentication
  include AuthenticatedSystem


  def index
    redirect_to shop_index_path
  end
  


end
