class CategoriesController < ApplicationController
  include Opensteam::Frontend::ShoppingCart
  
  layout Opensteam.configuration.opensteam_shop_controller
  
  before_filter :find_categories
  
  
  def index
    if params[:node].nil? || params[:node].to_i == 0
      @categories = Category.root_nodes
    else
      @categories = Category.find_children( params[:node] )
    end
    
    respond_to do |format|
      format.html
      format.xml { render :xml => @categories }
    end
  end


  def show
    @category = Category.find( params[:id], :include => :products )
  end
  
  
  def products
    show
    @products = @category.products
  end
  
  private
  def find_categories
    @categories = Category.root_nodes( :all, :include => :products ).active
  end
  



end
