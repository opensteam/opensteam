class OpensteamPropertyGenerator < Rails::Generator::NamedBase

  def initialize(runtime_args, runtime_options = {})
    super
  end
  
  def manifest

    record do |m|

      m.class_collisions class_path, class_name, "#{class_name}Test"

      # create directories
      m.directory( File.join( 'app/models', 'catalog' ) )

      # create model
      m.template( "models/property.rb", "app/models/catalog/#{file_name}.rb" )
      
    end
  end

  protected
  # Override with your own usage banner.
  def banner
    "Usage: #{$0} opensteam_property PropertyName"
  end

  def add_options!(opt)
    opt.separator ''
  end

  def scaffold_views
    %w[ index show new edit ]
  end

  def model_name
    class_name.demodulize
  end
end
