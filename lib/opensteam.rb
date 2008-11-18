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
require 'active_merchant'


=begin rdoc
opensteam

The +opensteam+ core provides functionality for web-based shopping and e-commerce
platforms.



=end


module Opensteam #:nodoc:
  def self._logger(*args) ; Opensteam::Initializer._logger( *args ) ; end
end

require 'opensteam/initializer'

Opensteam::Initializer.run do |config|
end


#Order = Opensteam::OrderBase::Order
Invoice = Opensteam::Models::Invoice
Shipment = Opensteam::Models::Shipment

OrderStates = Opensteam::OrderBase::States
InvoiceStates = Opensteam::InvoiceBase::States
ShipmentStates = Opensteam::ShipmentBase::States





