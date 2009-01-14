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


module Opensteam

  module System

    # Zones (Country Codes)
    class Zone < ActiveRecord::Base

      named_scope :name_ordered, { :order => 'zones.country_name ASC' }

      class << self ;

        def for_select(*args)
          return [] unless args
          name_ordered.map do |m|
            args.map { |a| m.__send__( a ) }
          end
        end

      end
    end

    # Quicksteams (Header Tabs in the Admin-Backend
    class QuickSteam < ActiveRecord::Base
      belongs_to :user

      def to_html( opts = {} )
        style = opts[:style] ? "style='#{opts[:style]}'" : ""
        "<a class='quicksteam_tab' id='quicksteam_#{self.id}' #{style} href='#{self.path}'><span>#{self.name}</span></a>"
      end

      def <=>(o)
        self.position <=> o.position
      end

    end


    class Mailer < ActiveRecord::Base
      self.table_name = "config_mails"
      #include Opensteam::System::FilterEntry::Filter

      named_scope :mailer_class, lambda { |mailer_class| { :conditions => { :mailer_class => mailer_class } } }
      named_scope :mailer_method, lambda { |mailer_method| { :conditions => { :mailer_method => mailer_method } } }
      named_scope :active, { :conditions => { :active => true } }

      def active? ; self.active ; end

      def activate!   ; self.update_attributes( :active => true )   ; end
      def deactivate! ; self.update_attributes( :active => false )  ; end


      def increment_messages ; self.increment!( :messages_sent ) ; end

      class << self ;

        def activate( klass, meth )
          mailer = mailer_class( klass.to_s ).mailer_method( meth.to_s )
          mailer.collect(&:activate!)
        end

        def deactivate( klass, meth )
          mailer = mailer_class( klass.to_s ).mailer_method( meth.to_s )
          mailer.collect(&:deactivate!)
        end

      end


    end

  end
end






