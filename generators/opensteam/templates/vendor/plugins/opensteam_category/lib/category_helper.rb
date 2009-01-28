module CategoryHelper

  def render_categories
    render :partial => "categories/category_sidebar", :object => @categories
  end
  

end
