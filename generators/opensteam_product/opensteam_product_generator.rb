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
	
      ### Controllers ###
      # direcotries
      m.directory( File.join('app/controllers', 'admin') )
      m.directory( File.join('app/controllers', 'admin', 'catalog' ) )
		
      # app/controllers/*
      m.template("controllers/catalog/product_controller.rb", "app/controllers/admin/catalog/#{table_name}_controller.rb")
			
      
      
      ### Models ###
      # app/models/* #
      m.template("models/product.rb", "app/models/#{file_name}.rb")
			
      
      
      ### Views ###
      m.directory( File.join('app/views', 'admin', 'catalog', table_name ) )
      # app/views/admin/<product>/* #
      %w( _categories _properties _attributes edit new show index ).each { |f|
        m.template("views/admin/#{f}.html.erb", "app/views/admin/catalog/#{table_name}/#{f}.html.erb")
      }
      m.file( "views/admin/_inventories.html.erb", "app/views/admin/catalog/#{table_name}/_inventories.html.erb")
      
      # app/views/<product>/* 
      m.directory( File.join('app/views', table_name ) )
      %w( _details _attr_product _attr_property ).each { |f|
        m.template("views/#{f}.html.erb", "app/views/#{table_name}/#{f}.html.erb")
      }
			
      
      
      ### Migrations ###
      unless options[:skip_migration]
        m.migration_template 'migration.rb', 'db/migrate', :assigns => {
          :migration_name => "CreateProducts#{class_name.pluralize.gsub(/::/, '')}"
        }, :migration_file_name => "create_products_#{file_path.gsub(/\//, '_').pluralize}"
      end
							
		
    end
  end

  protected
	
  def gsub_file(relative_destination, regexp, *args, &block)
    path = destination_path(relative_destination)
    content = File.read(path).gsub(regexp, *args, &block)
    File.open(path, 'wb') { |file| file.write(content) }
  end
		
		
  def map_add_namespace(str)
    logger.route "add admin namepsace for #{file_name}"
    sentinel = '  map.namespace :admin do |admin|'
			
    unless options[:pretend]
      gsub_file 'config/routes.rb', /(#{Regexp.escape(sentinel)})/mi do |match|
        "#{match}\n    admin.resources :#{str}\n"
      end
    end
  end
		
		
  def map_namedroutes(name, path, *r)
    route_list = r.inspect.gsub(/[\[\]{}]/, " ")
    sentinel = 'ActionController::Routing::Routes.draw do |map|'
			
    logger.route "map.#{name} \"#{path}\", #{route_list}"
    unless options[:pretend]
      gsub_file 'config/routes.rb', /(#{Regexp.escape(sentinel)})/mi do |match|
        "#{match}\n  map.#{name} \"#{path}\", #{route_list}\n"
      end
    end
  end
		
  def map_customroutes
  end
		
		
	
	
  # Override with your own usage banner.
  def banner
    "Usage: #{$0} opensteam_product ProductName [column:type] "
  end

  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on("--skip-timestamps",
      "Don't add timestamps to the migration file for this product") { |v| options[:skip_timestamps] = v }
    opt.on("--skip-migration",
      "Don't generate a migration file for this product") { |v| options[:skip_migration] = v }
  end

  def scaffold_views
    %w[ index show new edit ]
  end

  def model_name
    class_name.demodulize
  end
end
