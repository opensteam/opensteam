#	openSteam - http://www.opensteam.net
#  Copyright (C) 2009  DiamondDogs Webconsulting
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; version 2 of the License.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License along
#  with this program; if not, write to the Free Software Foundation, Inc.,
#  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

class Array

  # convert Array to Hash using a block for the key
  def to_h2() inject({}) { |h,o| h[yield(o)] ? h[yield(o)] << o : h[yield(o)] = [o] ; h } ; end

  # calculate permutations of an array, e.g. [[1,2], [3,4]].perm --> [[1,3], [1,4], [2,3], [2,4]]
  def perm(i=0, *h) return [h] if i == size ; self[i].map { |x| perm(i+1, *(h + [x])) }.inject([]) { |r,v| r + v } ; end


  # converts array to xml suitable for ExtJS
  def to_ext_xml options = {}
    raise "Not all elements respond to to_xml" unless all? { |e| e.respond_to? :to_xml }

    options[:indent] ||= 2
    options[:builder] ||= Builder::XmlMarkup.new( :indent => options[:indent] )
    options[:builder].instruct! unless options.delete( :skip_instruct )

    opts = options.merge( { :skip_instruct => true, :root => "Item" } )

    options[:builder].tag!( "Items") {
      options[:builder].tag!( "type", self.first.class.to_s.demodulize.tableize )
      options[:builder].tag!( "TotalResults", options[:total_entries] )
      options[:builder].Request { options[:builder].tag!( "IsValid", true ) }
      each { |e| e.to_ext_xml( opts ) }
    }

  end
  
end


unless Class.respond_to?( :get_subclasses )
  class Class
    # get all subclasses of the given klass
    def self.get_subclasses(klass)
      ObjectSpace.enum_for(:each_object, class << klass ; self ; end ).to_a
    end
  end
end


unless :symbol.respond_to?( :<=> )
  class Symbol
    def <=>(a)
      self.to_s <=> a.to_s
    end
  end
end



class ActionMailer::Base

  # check of mailer-class and mailer-method are active in Opensteam::System::Mailer, before delivering them
  def deliver_with_active_mailer_check!(mail = @mail )
    active_mailer = Opensteam::System::Mailer.mailer_class( self.class.to_s ).mailer_method( @action_name ).active
    return nil if active_mailer.empty?
    ret = deliver_without_active_mailer_check!(mail)
    active_mailer.collect(&:increment_messages)
    ret
  end

  alias_method_chain :deliver!, :active_mailer_check

end
