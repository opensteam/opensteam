class OpensteamPropertyGenerator < Rails::Generator::NamedBase

  def initialize(runtime_args, runtime_options = {})
    super
  end

  
  # check if the attribute.names (columns) already exists in the "properties" model (-> STI)
  # - ask Property-Model (columns)
  # - check previous migration-files
  #
  def migration_attributes
    properties_migrations = Dir.glob("db/migrate/*_create_properties_*.rb")
    a = attributes
    if Opensteam::Find.properties_table_exists?
      a.delete_if { |x| "Opensteam::Base::PropertyBase".constantize.columns.collect(&:name).include?( x ) }
    end
    a.delete_if { |x| 
      properties_migrations.inject(false) { |r,v| r ? true : File.read("#{v}").include?( "add_column :properties, :#{x.name}" ) }
    }
    a
  end
  
  
  def manifest

    record do |m|

      m.class_collisions class_path, class_name, "#{class_name}Test"
			
      
      
      ### Controllers
      m.directory( File.join('app/controllers', 'admin') )
      m.directory( File.join('app/controllers', 'admin', 'catalog' ) )


      # app/controllers/admin/* #
      m.template("controllers/property_controller.rb", "app/controllers/admin/catalog/#{table_name}_controller.rb")
	
      
      
      ### Models ###
      # app/models/* #
      m.template("models/property.rb", "app/models/#{file_name}.rb")
			
      
      
      ### Views ###
      # app/views/administratino/<property>/* #
      m.directory( File.join('app/views', 'admin', 'catalog', table_name ) )
      %w( _attributes edit index new ).each { |f|
        m.template("views/admin/#{f}.html.erb", "app/views/admin/catalog/#{table_name}/#{f}.html.erb")
      }

      
      ### Migrations ###
      unless options[:skip_migration]
        m.migration_template 'migration.rb', 'db/migrate', :assigns => {
          :migration_name => "CreateProperties#{class_name.pluralize.gsub(/::/, '')}"
        }, :migration_file_name => "create_properties_#{file_path.gsub(/\//, '_').pluralize}"
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
    "Usage: #{$0} opensteam_property PropertyName [column:type]"
  end

  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on("--skip-timestamps",
      "Don't add timestamps to the migration file for this property") { |v| options[:skip_timestamps] = v }
    opt.on("--skip-migration",
      "Don't generate a migration file for this property") { |v| options[:skip_migration] = v }
  end

  def scaffold_views
    %w[ index show new edit ]
  end

  def model_name
    class_name.demodulize
  end
end
