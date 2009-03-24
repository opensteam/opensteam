module OpensteamHelper

  def backend_image_tag(source, options = {})
    prefix_image_tag( :backend, source, options )
  end
  
  
  def frontend_image_tag( source, options = {} )
    prefix_image_tag( :frontend, source, options )
  end
  
  
  def prefix_image_tag( prefix, source, options = {} )
    image_tag( source =~ /^#{prefix}/ ? source : "#{prefix}/#{source}", options )
  end

end
