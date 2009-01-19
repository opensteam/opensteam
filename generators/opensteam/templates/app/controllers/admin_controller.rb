class AdminController < ApplicationController

  include Opensteam::Backend::Base

  layout 'admin'
  helper :all

  require_role :admin

  before_filter :set_locale
  before_filter :save_paging_and_sorting
  before_filter :get_quicksteams
  before_filter :save_breadcrumb

  def index
    @extensions = []
  end

  def save_breadcrumb
    profile_session.save_breadcrumb( request.request_uri, "#{self.controller_name} #{self.action_name}" ) if( !request.xhr? && request.get? )
  end
  
  def delete_breadcrumb
    profile_session.delete_breadcrumb
  end
  
  
  
  
  def add_property_group
    @product = Product.find( params[:product_id] )
    @product.property_groups.build( :selector => 'select', :selector_text => 'Please select ..' )
    @product.save
    render :head => :ok, :text => ""
  end
  

  def delete_all_filter
    profile_session.delete_all_filter( self )
    redirect_to :action => :index
  end



  def filter
    profile_session.save_filter( self, params[:filter] )
    redirect_to :action => :index
  end

  # payment types action --> TODO: replace with actual payment_types_controller.rb
  def payment_types
    @payment_types = Opensteam::Payment::Types.all
    render :template => "admin/system/payment_types/index"
  end

  
  def toggle_payment_type
    Opensteam::Payment::Types.find( params[:id] ).toggle!
    redirect_to :action => :payment_types
  end


  private
  
  # returns the profile session
  def profile_session
    @profile_session ||= ProfileSession.new( session )
  end
  helper_method :profile_session
  
  
  # save session information for current controller
  # (sorting, paging)
  def save_paging_and_sorting
    _s.sort = params[:sort] if params[:sort]
    _s.dir  = params[:dir] if params[:dir]
    _s.page = params[:page].to_i if params[:page]
    _s.per_page = params[:per_page].to_i if params[:per_page]
  end
  
  # returns session information for current controller
  def _s ; profile_session[ self ] ; end
  helper_method :_s
  
  
  
  # set localization
  def set_locale
    I18n.locale = params[:locale] if params[:locale]
  end
  
  def get_quicksteams
    @quicksteams = current_user.quick_steams
  end
  
  
  
  def authorized?
    unless logged_in? && is_admin?
      store_location
      redirect_to login_path
      return false
    end
    return true
  end


  def set_filter
    @filters = Opensteam::Helpers::Grid::FilterEntry.find( profile_session.active_filter( self ) )
  end

  
end