class AdminController < ApplicationController

  include Opensteam::Finder

  layout 'admin'
  helper :all

  require_role :admin

  before_filter :set_locale
  
  def set_locale
    I18n.locale = params[:locale] if params[:locale]
  end
  
  
  def profile_session
    @profile_session ||= ProfileSession.new( session )
  end
  helper_method :profile_session


  def index
    @extensions = []
    #   @extensions = Opensteam::ExtensionBase::Extension.active
  end


  # show property classes
  def properties
    @properties = AdminController.find_property_tables #AdministrationController.find_properties.collect(&:class).uniq
  end


  def delete_filter
    #  FilterEntry.find( params[:id] ).destroy
    session[:filter][ params[:model] ].delete( params[:id].to_i )
    redirect_to :action => :index
  end


  def delete_all_filter
    profile_session.delete_all_filter( self )
    redirect_to :action => :index
  end

  def filter
    profile_session.save_filter( self, params[:filter] )
    redirect_to :action => :index, :per_page => params[:per_page] || 20, :page => params[:page] || 1
  end



  def payment_types
    @payment_types = Opensteam::Payment::Types.all
    render :template => "admin/system/payment_types/index"
  end


  def toggle_payment_type
    Opensteam::Payment::Types.find( params[:id] ).toggle!
    redirect_to :action => :payment_types
  end


  def add_to_quicksteam
    QuickSteam.create( params[:quicksteam] )
    render :update do |page|

    end
  end


  private
  def authorized?
    unless logged_in? && is_admin?
      store_location
      redirect_to login_path
      return false
    end
    return true
  end


  def save_filter( model )
    session[:filter] ||= {}
    params[:existing_filter] ||= {} ;
    params[:new_filter] ||= [] ;

    session[:filter][model] ||= [] ;


    session[:filter][model].each do |i|
      puts i.inspect ;
      attributes = params[:existing_filter][i.to_s]
      if attributes
        f = Opensteam::System::FilterEntry.find( i )
        f.update_attributes( attributes ) if f
      else
        f = Opensteam::System::FilterEntry.find( i )
        puts f.inspect
        f.destroy if f
        session[:filter][model].delete( i )
      end
    end

    ( session[:filter][ model ] ||= [] ).push( *params[:new_filter].collect { |f| Opensteam::System::FilterEntry.create( f ).id } )


  end


  def apply_filter( model )

    session[:filter] ||= {}
    session[:filter][ model ] ||= []
    if session[:filter][ model ].empty?
      @filter_entries = [] ;
      return nil
    end

    @filter_entries = Opensteam::System::FilterEntry.find( session[:filter][ model ]  )
    return nil if @filter_entries.empty?

    model.classify.constantize.scoped(
      { :conditions => [ @filter_entries.collect(&:to_sql).join(" AND "),
          @filter_entries.collect(&:to_val).inject({}) { |r,v| r.merge(v) } ]
      }
    )
  end

  def set_filter
    @filters = Opensteam::System::FilterEntry.find( profile_session.active_filter( self ) )
  end

  
end