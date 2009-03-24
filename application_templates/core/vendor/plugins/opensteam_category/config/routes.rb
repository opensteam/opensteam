ActionController::Routing::Routes.draw do |map|

  map.namespace :admin do |admin|
    admin.namespace :catalog do |catalog|
      catalog.resources :categories, :collection => { :products => :get }
    end
  end
  
  map.resources :categories
end
