# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'fileutils'



RUBY_PATH = "c:\\ruby\\bin"
MAX_DUMMY_DATA = 100



namespace :opensteam do
  
  namespace :dummydata do
    desc "create dummy data"
    task :create => :environment do
      require 'populator'
      require 'faker'
      

      1.upto MAX_DUMMY_DATA do |order|

        payment_hash = {
          :set_credit_card => {
            :month => "10",
            :number => 1,
            :type => "bogus",
            :verification_value => "123",
            :year => "2010",
            :first_name => Faker::Name.name,
            :last_name  => Faker::Name.name
          }
        }

        payment_address_hash = { 
          "postal"=>Faker::Address.zip_code,
          "city"=> Faker::Address.city,
          "country"=> ["Austria", "Germany" ].rand,
          "firstname"=>Faker::Name.name,
          "lastname"=>Faker::Name.name,
          "street"=>Faker::Address.street_address
        }

        shipping_address_hash = { "postal"=>Faker::Address.zip_code,
          "city"=> Faker::Address.city,
          "country"=> ["Austria", "Germany" ].rand,
          "firstname"=>Faker::Name.name,
          "lastname"=>Faker::Name.name,
          "street"=>Faker::Address.street_address
        }

        order_hash = {
          :shipping_type => "Post",
          :payment_address => payment_address_hash,
          :shipping_address => shipping_address_hash,
          :payment_type => "credit_card"
        }

        guest_customer = { :login => Faker::Internet.user_name, :email => Faker::Internet.email }

        o = Opensteam::Models::Order.new( order_hash ) ;

        o.real_customer = User.new_or_existing_guest( guest_customer ) ;

        puts o.save
        puts o.customer.errors.inspect

        o.payments.build_payment( payment_hash )

        o.save
      end

    end
  
  end
  
  
  
  namespace :petstore do
    
    
    task :create do
      
      
      logger "welcome to the OpenSteam 'Petstore' sample application"
      
      logger "creating opensteam petstore products"
      
      system "ruby script/generate opensteam_product Animal name:string art:string type:string description:text picture:string"
      system "ruby script/generate opensteam_product DogFood name:string description:text"
            
      logger "creating opensteam petstore properties"
      system "ruby script/generate opensteam_property Weight name:string"
      system "ruby script/generate opensteam_property DogKind name:string"
            
      
      %w(dog fish reptile).each do |f|
        ff = File.open("app/models/#{f}.rb", 'w')
        ff.puts "require 'animal.rb'\nclass #{f.capitalize} < Animal\nend\n"
        ff.close
      end
      FileUtils.rm 'app/models/animal.rb', :force => true
      ff = File.open('app/models/animal.rb', 'w' )
      ff.puts "class Animal < ActiveRecord::Base\n  opensteam :product\n\n  def self.table_name() \"product_animals\" ; end\nend\n"
      ff.close
      
      
      logger "migrating"
      
      Rake::Task["db:migrate"].invoke
      
      logger "loading fixtures"
      
      require 'active_record'
      require 'active_record/fixtures'
      
      ENV['FIXTURES'] = "inventories_properties,properties,product_animals,inventories,product_dog_foods,region_shipping_rates,shipping_payment_additions,shipping_rate_groups,tax_groups,tax_rules,tax_zones,zones"
      ActiveRecord::Base.establish_connection( YAML.load_file("config/database.yml")["#{RAILS_ENV}"] )
      (ENV['FIXTURES'] ? ENV['FIXTURES'].split(/,/) : Dir.glob(File.join(RAILS_ROOT, 'test', 'fixtures', '*.{yml,csv}'))).each do |fixture_file|
        Fixtures.create_fixtures('test/fixtures', File.basename(fixture_file, '.*'))
      end
      
      
      
#      incl = "require 'has_many_polymorphs'"
#      sentinel = "Rails::Initializer.run do |config|"
#      gsub_file "config/environment.rb", /(#{Regexp.escape(sentinel)})/mi do |match|
#        "#{incl}\n\n#{match}"
#      end
      
      
      incl = <<ANIMAL_CONTR
    if params[:animal][:type] && ( params[:animal][:type].constantize.superclass == Animal)
      @animal = params[:animal][:type].classify.constantize.new( params[:animal] )
    else
      @animal = Animal.new(params[:animal])
    end
ANIMAL_CONTR
      
      sentinel = "@animal = Animal.new(params[:animal])"
      gsub_file "app/controllers/admin/catalog/animals_controller.rb", /(#{Regexp.escape(sentinel)})/mi do |match|
        "#{incl}\n\n"
      end
      
      logger "finished ... have fun !!"
      
      
    end
  end
  
  
end


	
def gsub_file(path, regexp, *args, &block)
  content = File.read(path).gsub(regexp, *args, &block)
  File.open(path, 'wb') { |file| file.write(content) }
end


def logger(str)
  puts "\n\t*** #{str} ****\n"
end
