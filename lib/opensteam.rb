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

require 'active_record'

=begin rdoc
opensteam

The +opensteam+ core provides functionality for web-based shopping and e-commerce
applications.

Opensteam can be created using application templates (rails 2.3)
In your template:
  
  require 'opensteam/template'
  
  opensteam do
    # generate the opensteam core (admin backend)
    core
    # generate all catalog files (mvc for products, properties and inventories)
    catalog
    # generate all sales files (mvc for orders, shipments and invoices)
    sales
    # generate an example frontend (shopping-cart, checkout process)
    frontend
  end
  
Make sure to provide a user-model (generate with restful_authentication). Default: "User"
The module "Opensteam::User::UserLogic gets included into the user model
=end

module Opensteam #:nodoc:
end

require 'opensteam/initializer'
