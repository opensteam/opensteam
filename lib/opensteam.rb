#	openSteam - http://www.opensteam.net
#  Copyright (C) 2008  DiamondDogs Webconsulting
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

require 'active_record'
#require 'active_merchant'


=begin rdoc
opensteam

The +opensteam+ core provides functionality for web-based shopping and e-commerce
platforms.



=end


module Opensteam #:nodoc:


  class Product

    class << self ;
      def models
        Opensteam::ProductBase.included_in_classes
      end

      def model_symbols
        models.collect { |s| s.to_s.underscore.to_sym }
      end


      # check if type is a product class first!!
      def find( type, id, *options )
        type.to_s.classify.constantize.find( id, *options )
      end

    end



  end


end

require 'opensteam/initializer'
