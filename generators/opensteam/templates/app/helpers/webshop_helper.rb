# Methods added to this helper will be available to all templates in the application.
## TEMPLATE ##
module <%= class_name %>Helper
  
  include Opensteam::Money::Helper

  # return first partial-file that exist in *a
  def existing_partial( *a )
    a.each { |v| return v if File.exist?( "#{RAILS_ROOT}/app/views/#{File.split(v)[0]}/_#{File.split(v)[1]}.html.erb" ) }
  end
  
  def ordinalized_time(time = Time.now)
    time.strftime("%d-%m-%Y %H:%M:%S")
  end 
  
  def shop_menu_links
    returning("") do |str|
      str.concat( link_to( "Index", opensteam_index_path ) )
      str.concat( link_to( "Search", new_search_path ) )
      if logged_in?
        str.concat( link_to( "Logout", logout_path) )
        str.concat( link_to( "admin", admin_path ) ) if current_user.is_a?( Opensteam::UserBase::Admin )
      else
        str.concat( link_to("Login", login_path) ) 
        str.concat( link_to( "Register", signup_path) ) 
      end
    end
    
  end

  
end