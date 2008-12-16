####
# extend Array
class Array
  
  # convert Array to Hash using a block for the key
  def to_h2() inject({}) { |h,o| h[yield(o)] ? h[yield(o)] << o : h[yield(o)] = [o] ; h } ; end
  
  # calculate permutations of an array, e.g. [[1,2], [3,4]].perm --> [[1,3], [1,4], [2,3], [2,4]]
  def perm(i=0, *h) return [h] if i == size ; self[i].map { |x| perm(i+1, *(h + [x])) }.inject([]) { |r,v| r + v } ; end
  
end


class Class
  # get all subclasses of the given klass
  def self.get_subclasses(klass)
    ObjectSpace.enum_for(:each_object, class << klass ; self ; end ).to_a
  end
end

require 'opensteam/inventory_base'
Inventory = Opensteam::Models::Inventory

# require all models
Dir.glob("#{RAILS_ROOT}/app/models/*.rb").collect { |f| require f }

# define property_accessors for Inventory-objects
Inventory.define_property_accessors

Opensteam::Payment::Types.register_payment_types!if ActiveRecord::Base.connection.table_exists?( "payment_types" )



Order = Opensteam::Models::Order
Zone = Opensteam::System::Zone
Opensteam::UserBase::User = User





# RemoteLink Renderer Class for WillPaginate
# used for ajax pagination
class RemoteLinkRenderer < WillPaginate::LinkRenderer
  def prepare(collection, options, template)
    @remote = options.delete(:remote) || {}
    super
  end

  protected
  def page_link(page, text, attributes = {})
    @template.link_to_remote(text, {:url => url_for(page), :method => :get}.merge(@remote))
  end
end


module Prawnto
  module TemplateHandler
    class Base < ActionView::TemplateHandler
      def self.compilable?
        false
      end

      def compile(template)
      end
    end
  end
end


require 'opensteam_extensions'

#module ActionView # :nodoc:
#  require 'pdf/writer'
#  class PDFRender
#    PAPER = 'A4'
#    include ApplicationHelper
#    include ActionView::Helpers::AssetTagHelper
#    include ActionView::Helpers::TextHelper      
#    include ActionView::Helpers::TagHelper
#    include ActionView::Helpers::UrlHelper
# 
#    def initialize(action_view)
#      @action_view = action_view
#    end
# 
#    # Render the PDF
#    def render(template, local_assigns = {})
#      @action_view.controller.headers["Content-Type"] ||= 'application/pdf'
# 
#      # Retrieve controller variables
#      @action_view.controller.instance_variables.each do |v|
#        instance_variable_set(v, @action_view.controller.instance_variable_get(v))
#      end
# 
#      pdf = ::PDF::Writer.new( :paper => PAPER )
#      pdf.compressed = true if RAILS_ENV != 'development'
#      eval template.source, nil, "#{@action_view.base_path}/#{@action_view.first_render}.#{@action_view.finder.pick_template_extension(@action_view.first_render)}" 
# 
#      pdf.render
#    end
# 
#    def self.compilable?
#      false
#    end
# 
#    def compilable?
#      self.class.compilable?
#    end
#  end
#end






