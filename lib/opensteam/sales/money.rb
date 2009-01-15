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

  # Module Module
  #
  # all money specific classes and modules (tax_groupd/zones, tax calculation, rounding, etc)
  module Money


    # View Helper
    module Helper

      # returns the tax raet for given item and country.
      # if country is given, the defualt_country is used (if defined in Opensteam::Config)
      def get_rate_for item, country = nil
        item.get_rate( :country => country || Opensteam::Config[ :default_country ] )
      end

      # returns the calculated tax for given item and country
      def calculate_tax_for item, country = nil
        item.calculate_tax( :country => country || Opensteam::Config[ :default_country ] )
      end
      
    end

    

    # Module for money rounding
    module Rounding
      
      # normal rounding
      def round f
        BigDecimal.new( f.to_s ).round(2)
      end
      
      
      # rappen rounding (for CH)
      def round_rappen f
        ( BigDecimal.new( f.to_s ) * 20 ).round / 20
      end
    
    end
    
    
    
    
    # Tax Module
    module Tax
      

      # Tax Calculation Module
      # included into order_items or inventory-items
      module Calculation
        include Opensteam::Sales::Money::Rounding

        # returns the calculated tax for given address and current item
        def calculate_tax( address )
          round( self.price * ( get_rate( address ) / 100  ) )
        end

        # returns rate for given address and current tax_group
        def get_rate( address )
          return 0.0 unless self.tax_group
          
          zones = self.tax_group.tax_zones.by_address( address ) 
          
          if !zones || zones.empty?
            return 0.0
          else
            zones.first.rate
          end
          
        end
        
        
        
      end
      

      
      # TaxZone Model
      # defines rates for specific zones/countries/states
      class TaxZone < ActiveRecord::Base
        self.table_name = "tax_zones"
        

        has_many :tax_rules, :class_name => "Opensteam::Sales::Money::Tax::TaxRule"
      
        named_scope :order_by, lambda { |by| { :order => Array(by).join(",") } }
        named_scope :by_product_tax_group, lambda { |a| { :include => { :tax_rules => :product_tax_group },
            :conditions => { "tax_groups.name" => a } } }
      
        named_scope :by_address, lambda { |a| { :conditions => a } }

      end
    
    
    
      # TaxGroup Model
      # STI Base Class
      class TaxGroup < ActiveRecord::Base
        self.table_name = "tax_groups"
        named_scope :order_by, lambda { |by| { :order => Array(by).join(",") } }
      
      end
    
    
      # Tax Groups for a Custmoer, not yet implemented !!
      class CustomerTaxGroup < TaxGroup
      
        has_many :customers, :class_name => "Opensteam::UserBase::User", :foreign_key => "tax_group_id" 
      
        has_many :tax_rules, :foreign_key => "customer_tax_groupd_id", :class_name => "Opensteam::Sales::Money::Tax::TaxRule"
        has_many :tax_zones, :through => :tax_rules, :class_name => "Opensteam::Sales::Money::Tax::TaxZone"
      end


    
      # TaxGroup Model for Products
      # associates products with a tax-group
      class ProductTaxGroup < TaxGroup
      
        has_many :inventories, :class_name => 'Opensteam::Models::Inventory', :foreign_key => "tax_group_id"
      
        has_many :tax_rules, :foreign_key => "product_tax_group_id", :class_name => "Opensteam::Sales::Money::Tax::TaxRule"
        has_many :tax_zones, :through => :tax_rules, :class_name => "Opensteam::Sales::Money::Tax::TaxZone"
      
        validates_presence_of :name
        validates_uniqueness_of :name
      
        after_update :save_tax_rules


        def new_tax_rule_attributes=( rule_attributes )
          rules = []
          rule_attributes.each do |attributes|
            tax_rules.build( attributes ) unless rules.include?( attributes["tax_zone_id"] )
            rules << attributes["tax_zone_id"]
          end
        end
      
        def existing_tax_rule_attributes=( rule_attributes )
          tax_rules.reject(&:new_record?).each do |tax_rule|
            attributes = rule_attributes[tax_rule.id.to_s]
            if attributes
              tax_rule.attributes = attributes
            else
              tax_rules.delete( tax_rule )
            end
          end
        end
      
        def save_tax_rules
          tax_rules.each { |rule| rule.save(false) } 
        end
      
      
        def tax_rules=( rules )
          return false unless save
          self.tax_rules.delete_all
          rules.each { |r| self.tax_rules.create( r ) }
        end
      
      end
    
    
    
      # TaxRules
      # groups set of TaxZones with TaxGroups
      class TaxRule < ActiveRecord::Base
        self.table_name = "tax_rules"
     
      
        belongs_to :customer_tax_group, :class_name => "Opensteam::Sales::Money::Tax::TaxGroup"
        belongs_to :product_tax_group, :class_name => "Opensteam::Sales::Money::Tax::TaxGroup"
      
        belongs_to :tax_zone
  
        named_scope :by_product_tax_group, lambda { |p| { :include => :product_tax_group, :conditions => { "tax_groups.name" => p } } }
      end

      
      

    end
    
    
  end
  
end


### Aliases ######
TaxZone = Opensteam::Sales::Money::Tax::TaxZone
TaxRule = Opensteam::Sales::Money::Tax::TaxRule
TaxGroup = Opensteam::Sales::Money::Tax::TaxGroup
ProductTaxGroup = Opensteam::Sales::Money::Tax::ProductTaxGroup
CustomerTaxGroup = Opensteam::Sales::Money::Tax::CustomerTaxGroup


# include TaxCalculation logic into Opensteam::Container::Item
Opensteam::Container::Item.send( :include, Opensteam::Sales::Money::Tax::Calculation )







