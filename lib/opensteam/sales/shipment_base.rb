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

module Opensteam::Sales


  module ShipmentBase


    # available States for an Shipment-Instance
    module States

    end

    
    module ShippingCalculation
      
      def calculate_shipping_rate attr = {} 
        send( "shipping_rate_#{Opensteam::Config[:shipping_strategy]}", attr )
      end
      
      
      def set_shipping_rate!
        returning( self ) do |s|
          s.shipping_rate = ( r = calculate_shipping_rate ).is_a?( Array ) ? r.sum : r
          s.total_price += s.shipping_rate
        end
        #        self.update_attribute( :shipping_rate, ( r = calculate_shipping_rate ).is_a?( Array ) ? r.sum : r )
      end
      
      
      
      def shipping_rate_per_order attr
        set_shipping_attributes( attr )

        ShippingRateGroup.find_by_name( attr[:group_name] ).rate_for( attr )
      end
      
      

      def shipping_rate_per_item attr
        set_shipping_attributes( attr )
        
        self.items.collect { |i|
          ShippingRateGroup.find_by_name( i.shipping_rate_group ).rate_for( attr ) rescue 0.0
        }
      end
      
      
      def set_shipping_attributes( attr )
        attr[:payment_type] = self.payment_type unless attr[:payment_type]
        attr[:shipping_method] = self.shipping_type unless attr[:shipping_method]
        attr[:country] = self.shipping_address.country unless attr[:country]
        attr[:group_name] = Opensteam::Config[:shipping_rate_group_default] unless attr[:group_name]
      end
      
      private :set_shipping_attributes
      
    end
    

    def self.included(base)
      base.send( :extend, ClassMethods )
      base.send( :include, InstanceMethods )
      
      base.class_eval do
        include Opensteam::StateMachine
      
        belongs_to :order, :class_name => 'Opensteam::Models::Order'
        belongs_to :customer, :class_name => 'User'
        belongs_to :address, :class_name => 'Opensteam::UserBase::Address'
      
        has_many :items, :class_name => 'Opensteam::Container::Item'
        alias :order_items :items
            
        named_scope :by_order, lambda { |order_id| { :include => :order, :conditions => { :order_id => order_id } } }
        
      end
    end


    module ClassMethods
    end


    module InstanceMethods
      
      def initialize(*args)
        super(*args)

        if order
          self.address = order.shipping_address
          self.customer = order.customer
        end
      end

    end
    
    
    # Model for Shipping Rate Groups
    class ShippingRateGroup < ActiveRecord::Base
      has_many :shipping_rates,
        :class_name => 'Opensteam::Sales::ShipmentBase::RegionShippingRate',
        :dependent => :destroy
  
      has_many :zones,
        :class_name => 'Opensteam::System::Zone',
        :through => :shipping_rates
  
      has_many :payment_additions,
        :class_name => 'Opensteam::Sales::ShipmentBase::ShippingPaymentAddition'
  

      validates_presence_of :name
      validates_uniqueness_of :name
  
      validates_associated :shipping_rates
      validates_associated :payment_additions

      after_update :save_shipping_rates, :save_payment_additions
  
  
      def rate_for( attr = {} )
        conditions = {
          "zones.country_name" => attr[:country] || Opensteam::Config[:default_country],
          "region_shipping_rates.shipping_method" => attr[:shipping_method] || Opensteam::Config[:shipping_method_default]
        }
        #        conditions = {}
        #        conditions["zones.country_name"] = attr[:country] || Opensteam::Config[:default_country]
        #        conditions["region_shipping_rates.shipping_method"] = attr[:shipping_method] || Opensteam::Config[:shipping_method_default]
    
        srate = shipping_rates.find( :first, :include => :zone, :conditions => conditions )
 
        rate = unless srate
          shipping_disabled ? 0.0 : master_rate.to_f
        else
          srate.rate
        end
    
        rate += get_payment_additions( attr[:payment_type] ) if attr[:payment_type]
 
        rate
      end
  
  
  
  
  
      private
  
      def get_payment_additions( payment_type )
        if ( pa = payment_additions.find(:first, :conditions => { :payment_type => payment_type } ) )
          pa.amount
        else
          0.0
        end
      end
  
  

      def new_payment_additions=( pa )
        pa.each do |r|
          payment_additions.build( r )
        end
      end

    
      def existing_payment_additions=( pa )
        payment_additions.reject(&:new_record?).each do |paddition|
          attributes = pa[ paddition.id.to_s ]
          if attributes
            paddition.attributes = attributes
          else
            payment_additions.delete( paddition )
          end
        end
      end
  
  
      def new_rates=( rates )
        rates.each do |r|
          shipping_rates.build( r )
        end
      end
  
      def existing_rates=( rates )
        shipping_rates.reject(&:new_record?).each do |rate|
          attributes = rates[ rate.id.to_s ]
          if attributes
            rate.attributes = attributes
          else
            shipping_rates.delete( rate )
          end
        end

      end
  
  

      def validate
        if shipping_rates.empty?
          if self.master_rate.blank? && !self.shipping_disabled
            errors.add_to_base( "Either add Shipping Rates or define a default rate!" )
            errors.add( :shipping_rates, "Cannot be empty!" )
            errors.add( :master_rate, "Cannot be empty!" )
            errors.add( :shipping_disabled, "" )
          end
        end
      end

      def save_shipping_rates
        shipping_rates.each { |s| s.save(false) }
      end
  
      def save_payment_additions
        payment_additions.each { |s| s.save(false) }
      end

  
  
    end

    
    # Model for ShippingRate depending on Region (Zone, Country, .. )
    class RegionShippingRate < ActiveRecord::Base
  
      belongs_to :group,
        :class_name => 'Opensteam::Sales::ShipmentBase::ShippingRateGroup'
  
      belongs_to :zone,
        :class_name => 'Opensteam::System::Zone'
  
  
      ## named scopes
      
      # find all by country-name and shipping-method-name
      named_scope :by_country_and_shipping_method, lambda { |country, sm|
        { :include => :zone,
          :conditions => { "zones.country_name" => country, :shipping_method => sm }
        }
      }
  
      # find all by country-name
      named_scope :by_country_name, lambda { |country_name|
        { :include => :zone, :conditions => { "zones.country_name" => country_name } }
      }
  
      # find all by shipping-method-name
      named_scope :by_shipping_method, lambda { |shipping_method|
        { :conditions => { :shipping_method => shipping_method } }
      }
  
    end
    
    
    
    
    # Model for ShippingRate Additions depending on the payment_type
    class ShippingPaymentAddition < ActiveRecord::Base
      self.table_name = "shipping_payment_additions"
      
      belongs_to :shipping_rate_group,
        :class_name => "Opensteam::Sales::ShipmentBase::ShippingRateGroup"
      
      validates_uniqueness_of :payment_type, :scope => [ :shipping_rate_group_id ]
      
    end
    
    
    
    
    
  end

end
