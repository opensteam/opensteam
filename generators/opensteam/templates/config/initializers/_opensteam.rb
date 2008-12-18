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



unless :symbol.respond_to?( :<=> )
  class Symbol
    def <=>(a)
      self.to_s <=> a.to_s
    end
  end
end



require 'opensteam/inventory_base'
Inventory = Opensteam::Models::Inventory
Dir.glob("#{RAILS_ROOT}/app/models/*.rb").each { |f| require f }

# define property_accessors for Inventory-objects
Inventory.define_property_accessors

Opensteam::Payment::Types.register_payment_types!if ActiveRecord::Base.connection.table_exists?( "payment_types" )



Order = Opensteam::Models::Order
Zone = Opensteam::System::Zone
Opensteam::UserBase::User = User



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







