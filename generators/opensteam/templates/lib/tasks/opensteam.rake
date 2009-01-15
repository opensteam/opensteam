
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
 
  
end


	
def gsub_file(path, regexp, *args, &block)
  content = File.read(path).gsub(regexp, *args, &block)
  File.open(path, 'wb') { |file| file.write(content) }
end


def logger(str)
  puts "\n\t*** #{str} ****\n"
end
