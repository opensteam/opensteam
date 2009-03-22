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

class OpensteamProductGenerator < Rails::Generator::NamedBase

  def initialize(runtime_args, runtime_options = {})
    super
  end

  def manifest
    record do |m|
     
      m.class_collisions class_path, class_name, "#{class_name}Test"

      # create directories
      m.directory( File.join('app/models/catalog') )
      m.directory( File.join('app/views/webshop' ) )
      m.directory( File.join('app/views/webshop/products' ) )
      m.directory( File.join('app/views/webshop/products', table_name ) )

      # create model
      m.template('models/product.rb', "app/models/catalog/#{file_name}.rb" )

      # create views
      scaffold_views.each do |v|
        m.template("views/#{v}.html.erb", "app/views/webshop/products/#{table_name}/#{v}.html.erb")
      end
    end
  end

  protected
	
	
  # Override with your own usage banner.
  def banner
    "Usage: #{$0} opensteam_product ProductName"
  end

  def add_options!(opt)
    opt.separator ''
  end

  def scaffold_views
    %w[ _show ]
  end

  def model_name
    class_name.demodulize
  end
end
