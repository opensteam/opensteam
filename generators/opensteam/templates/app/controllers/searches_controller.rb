## TEMPLATE ##
class SearchesController < ApplicationController
  def new
    @search = Search.new
  end
  
  def create
    
    params[:search][:properties] = params[:properties].values if params[:properties]
    
    
    @search = Search.new(params[:search])
    if @search.save
      flash[:notice] = "Successfully created search."
      redirect_to @search
    else
      render :action => 'new'
    end
  end
  
  def show
    @search = Search.find(params[:id])
    @products = ( @search.products || [] ) rescue []
    flash[:notice] = @products.empty? ? "No products found!!" : "Search results:"
    render :template => "<%= file_name %>/index"
  end
end
