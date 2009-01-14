module AdminHelper

  ##### NAVIGATION #####
  
  # returns the right class for an active sidebar navigation link
  def nav_link_class( active, current )
    ( active.to_sym == current.to_sym ) ? "editor-navi-item-active" : "editor-navi-item"
  end
  
  # renders property navigation sidebar
  def property_navigation( property, opts = {} )
    active = opts[:active] || :general
    content_tag( :div, "Property Configuration", { :class => "dvEditorNaviHeadline" } ) +
      content_tag( :div, { :class => "dvEditorNaviItems" } ) do
    	link_to( "General Information", [:admin, :catalog, property ], :id => "general", :class => nav_link_class(active, :general) )
    end
  end
  
  # renders a link for product-extensions (sidebar in product-pages)
  # used for product-plugins, like 'categories'
  def product_extension_links( product, active, disabled = false )
    Opensteam::Extension.product_extensions.collect do |ext|
      disabled ?
        link_to_function( ext.to_s.humanize, "alert('Save your product first!'); return false; ", :id => ext.to_s, :class => nav_link_class( active, ext ) ) :
        link_to( ext.to_s.humanize, admin_catalog_product_ext_path( product, ext ), :id => ext.to_s, :class => nav_link_class( active, ext ) )
    end.join(" ")
  end

  def product_path( product )
    product.new_record? ? new_admin_catalog_product_path : admin_catalog_product_path( product )
  end
  


  # renders product navigation sidebar
  def product_navigation( product, opts = {} )
    active = opts[:active] || :general
    content_tag( :div, "Product Configuration", { :class => "dvEditorNaviHeadline" } ) +
      content_tag( :div, { :class => "dvEditorNaviItems" } ) do
    	link_to( "General Information", product_path( product ), :id => "general", :class => nav_link_class(active, :general) ) +
        ( product.new_record? ?
          link_to_function('Property Groups', "alert('Save your product first!'); return false;", :class => nav_link_class(active, :property_groups ) ) +
          link_to_function("Inventories", "alert('Save your product first!'); return false;", :class => nav_link_class(active, :inventories ) ) +
          product_extension_links( product, active, true ) :
          link_to( "Property Groups", admin_catalog_product_property_groups_path( product ), :id => "property_groups", :class => nav_link_class( active, :property_groups ) ) +
          link_to( "Inventories", admin_catalog_product_inventories_path( product ), :id => "inventories", :class => nav_link_class(active, :inventories ) ) +
          product_extension_links( product, active ) )
    end
  end
  
  # navigation item
  def admin_nav_item c
    cname = c.controller_name.upcase
    content_tag :div, {
      :id => "dvNaviItem_#{c.controller_name.upcase}",
      :class => "dvNaviItem"
    } do
      content_tag( :div, "", { :class => "dvNaviItem_left" } ) +
        content_tag( :div, link_to( cname, { :controller => c.controller_path, :action => 'index' } ),
        { :class => "dvNaviItem_main",
          :onmouseover => "DD.navi.doCheckForSubs( this.parentNode, '#{cname}', 'down', false ); ",
          :onmouseout  => "DD.navi.doHideSubs( this.parentNode, '#{cname}', false ) ; "
        } ) +
        content_tag( :div, "", { :class => "dvNaviItem_right" } ) +
        content_tag( :div, "", { :class => "clearer" } )
    end
  end
  
  
  
  # sidebar navigation for orders
  def order_navigation( order, opts = {} )
    active = opts[:active] || :general
    content_tag( :div, t(:order) + " Information", { :class => "dvEditorNaviHeadline" } ) +
      content_tag( :div, { :class => "dvEditorNaviItems" } ) do
    	link_to( t(:general_information), admin_sales_order_path( order ), :id => "general", :class => nav_link_class(active, :general) ) +
        link_to( t(:invoices), admin_sales_order_invoices_path( order ), :class => nav_link_class(active, :invoices ) ) +
        link_to( t(:shipments), admin_sales_order_shipments_path( order ), :class => nav_link_class(active, :shipments ) )
    end
  end
  
  
  ##### HEADLINE  #########
  
  
  # renders the headline and an image (along with path information for quicksteam dragndrop)
  def render_headline id, title, img
    content_for( :headline ) do
      image_tag( img, :alt => '', :id => id, :title => "buh") + content_tag(:span, title, :id => "#{id}_title" ) +
        content_tag(:div, request.request_uri, :class => "draggable_path", :style => "display:none;", :id => "#{id}_path") +
        draggable_element( id, :revert => true, :onDrag => "positionDivPath", :onStart => "showDivPath", :onEnd => "hideDivPath" )
    end
  end
  
  
  # render "add to quicksteam" link
  # per default: Ajax call to admin_system_quicksteams_path with name and path as defined in "render_headline"
  # quicksteam-list update is handled through quicksteams_controller + rjs
  def add_quicksteam_link( opts = {} )
    opts[:icon] ||= 'content-header/icon_sun.gif'
    opts[:text] ||= 'Add to quicksteam'
    opts[:context_id] ||= 'categories'
    opts[:url] ||= admin_system_quicksteams_path
    if opts[:quicksteam_name] && opts[:quicksteam_path]
      opts[:with] = "'quicksteam[path]=#{opts[:quicksteam_path]}&quicksteam[name]=#{opts[:quicksteam_name]}'"
    else
      opts[:with] ||= "'quicksteam[path]=' + $('#{opts[:context_id]}_icon_path').innerHTML + '&quicksteam[name]=' + $('#{opts[:context_id]}_icon_title').innerHTML"
    end
    
    link_to_remote( content_tag( :span, image_tag( opts[:icon] ) + opts[:text] ),
      :url => opts[:url],
      :method => :post,
      :with => opts[:with] )
  end
  
  
  # render header buttons for a page
  # + "add to quicksteam"
  # + "print page"
  # + "Save" or "New" or no button
  def render_header_buttons title = nil, options = {}
    options[:class] ||= 'add-button'
    content_for( :content_header_buttons ) do
      add_quicksteam_link +
        link_to( content_tag( :span, image_tag( 'content-header/icon_print.gif') + "Print page" ), '#' ) +
        if title.nil?
        ""
      elsif options[:href]
        link_to( content_tag( :span, title ), options[:href], :class => options[:class] )
      elsif options[:form_id]
        link_to_function( content_tag( :span, title ), "$('#{options[:form_id]}').submit();", :class => options[:class] )
      end
    end
  end
  
  
  
  
  #### PATH HELPER for polymorphic PRODUCTS ######
  
  # path helper for products
  # def admin_catalog_product_inventories_path( product, options = {} )
  #   instance_eval( "admin_catalog_#{product.class.to_s.underscore.singularize}_inventories_path( product, options )" )
  # end
  
   # another path helper for products
   def admin_catalog_product_x_path( product, x, options = {} )
     instance_eval( "admin_catalog_#{product.class.to_s.underscore.singularize}_#{x}_path( product, options ) " )
   end
   # another path helper for products
   def admin_catalog_product_ext_path( product, x, options = {} )
     instance_eval( "admin_catalog_product_#{x}_path( product, options ) " )
   end
  
  
  
  
  
  
  
  #### EXT JS GRID ######
  
  # render a grid table (Ext JS)
  def grid_table id = "the-table", url = nil, fields = [], filter_fields = nil, &block
    raise ArgumentError unless block_given?
    filter_fields ||= fields
    concat(
      content_tag( :table, capture( &block ), { :cellpadding => "0", :cellspacing => "0", :id => id } ) +
        javascript_tag("createGrid('#{id}','#{url}', #{fields.collect(&:to_s).to_json});")
    )
  end
  
  
  # render a local grid table (ExtJs but without remote xml)
  # and without javascript call (used for grid-tables in ExtJs tabbed view -> transform to ExtJs grid if tab is activated)
  def grid_table_local id = "the-table", &block
    raise ArgumentError unless block_given?
    concat( 
      content_tag( :table, capture(&block), { :cellpadding => "0", :cellspacing => "0", :id => id, :style => "width:100%;"} )
    )
  end
  
  # render a local grid table (ExtJs but without remote xml)
  # transforms an existing <table> into an ExtJs grid.
  def grid_table_static id = "the-table", &block
    raise ArgumentError unless block_given?
    concat(
      content_tag( :table, capture(&block), { :cellpadding => "0", :cellspacing => "0", :id => id } ) +
        javascript_tag("createLocalGrid('#{id}', null);")
    )
  end
  

  
  ##### DIV #####
  
  
  def render_breadcrumbs
    profile_session.breadcrumbs.collect { |s|
      link_to s.last, s.first 
    }.join(" > ")
  end
  
  
  # renders a link to add new tax_rules
  def add_tax_rule_link(name)
    link_to_function "<span>#{name}</span>", :class => 'green-button', :style => "float:left;" do |page|
      page.insert_html :bottom, :tax_rules, :partial => 'tax_rule', :object => Opensteam::Sales::Money::Tax::TaxRule.new
    end
  end

  
  # images for user events
  def self.user_event_images
    { :suspend => "user_blocked.png", :delete => "user_delete.png", :register => "", :unsuspend => "user_go.png", :activate => "user_go.png" }
  end

  
end