# Methods added to this helper will be available to all templates in the application.
## TEMPLATE ##
module AdminHelper
  
  
  def button_to_with_image( image, args )
    form_tag :action => args[:action], :id => args[:id] do
      image_submit_tag( image )
    end
  end
  
  def submit_tag_with_image( text, image, args = { :confirm => "Are Your Sure?" } )
    args[:name] = text
    args[:type] = 'image'
    args[:src] = image_path( image )
    submit_tag(text, args )
  end
  
  
  def admin_sidebar_links(opts = { :html => { :class => "sub_menu" } }, &block )
    html_options = opts[:html]
    content = capture( &block )
    concat(
      content_tag(:ul, html_options) do
        content
      end,
      block.binding
    )
  end
  
  def admin_sidebar_link( name, path, opts = {} )
    html_options = opts[:html]
    
    content_tag(:li, html_options ) do
      opts[:function] ? link_to_function(name, opts[:function] ) : link_to( name, path )
    end
    
  end
  
  def add_tax_rule_link(name)
    link_to_function name do |page|
      page.insert_html :bottom, :tax_rules, :partial => 'tax_rule', :object => Opensteam::Money::Tax::TaxRule.new
    end
  end
  
  def header_with_links( name, *links )
    content_tag( :div, { :class => "header_with_links" } ) do
      content_tag( :h3, name, {} ) + links.join("")
    end
  end
  
  def mailer_classes
    Opensteam::Mailer.constants.map { |c| c.constantize < ActionMailer::Base ? c.to_s : nil }.compact
  end

  def render_headline id, title, img
    content_for( :headline ) do
      image_tag( img, :alt => '', :id => id ) + title
    end
  end
  
  def render_header_buttons title = nil, options = {}
    content_for( :content_header_buttons ) do
      link_to( content_tag( :span, image_tag( 'content-header/icon_sun.gif') + "Add to quicksteam" ), '#' ) +
        link_to( content_tag( :span, image_tag( 'content-header/icon_print.gif') + "Print page" ), '#' ) +
        if title.nil?
        ""
      elsif options[:href]
        link_to( content_tag( :span, title ), options[:href], :class => 'add-button' )
      elsif options[:form_id]
        link_to_function( content_tag( :span, title ), "$('#{options[:form_id]}').submit();", :class => 'add-button')
      end
    end
  end

  def button_image_to( _erbout, name, image, args = {} )
    form_tag args do
      concat( image_submit_tag( image ), binding )
    end
  end


  def self.user_event_images
    { :suspend => "error.png", :delete => "cross.png", :register => "", :unsuspend => "tick.png", :activate => "tick.png" }
  end

  def event_buttons_for(_erbout,  user )
    user.aasm_events_for_current_state.reject { |r| r == "register" }.collect do |event|
      button_image_to( _erbout, event.to_s,
        AdminHelper.user_event_images[event],
        :action => 'update', :method => 'put', :event => event.to_s )
    end.join("")
  end


  
end