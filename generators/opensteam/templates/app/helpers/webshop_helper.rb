# Methods added to this helper will be available to all templates in the application.
## TEMPLATE ##
module <%= class_name %>Helper
  
  include Opensteam::Helpers::ConfigTableHelper::HelperMethods
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

  
  def render_configured_table( mdl, opts = {}, &block )
    mdl = mdl.to_s.classify.constantize unless mdl.is_a?(Class)
    
    html_options = opts[:html] || {}
    
    content = capture( &block )
    html_options[:id] ||= mdl.configured_table.table_id
    
    concat(
      content_tag( :div, { :class => 'configured_table' } ) do
        content_tag( :table, html_options ) do
          content
        end
      end, 
      block.binding )
    
  end
    
    
    

  def render_configured_table_header(mdl,  partial = nil, opts = {}, &block )

    mdl = mdl.to_s.classify.constantize unless mdl.is_a?(Class)
    if partial 
      return controller.render_to_string( partial, :object => mdl.configured_table.columns.collect(&:name) )
    end
  
    table_id = mdl.configured_table.table_id
      
    ct = mdl.configured_table
    html_options = opts[:html]
    content_tag( :thead, {} ) do
      content_tag( :tr, html_options ) do
        ct.columns.collect do |column|
          content_tag( :th, {} ) do
            if block_given?
              block.call(column)
            else
              link_to_remote( column.name,
                :url => { :controller =>"admin/#{controller.controller_name}", :action => 'sort', :model => 'Order', :sort => column.id },
                :update => table_id )
            end
          end
        end.to_s
      end
    end

  end
  

  
  

  

  def render_configured_table_content( *opts )
    opts = opts.first unless opts.is_a?(Hash)
    if  opts[:partial]
      return content_tag( :tbody, :id => opts.delete(:id) ) do
        controller.render_to_string(opts)
      end
    end
  end
  
  
end