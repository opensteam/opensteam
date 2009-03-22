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

module Opensteam::Product


  # Opensteam Logic for Product Model
  #
  # This Module is meant to be included into the actual Opensteam Product Model.
  # It provides the basic product functionality and associations.
  #
  # The Product Model defines the Base Class of a Product. Using SingleTableInheritance, more complicated product can be built.
  module Logic

    # hold product extension modules (like categories)
    mattr_accessor :product_extensions
    self.product_extensions = []

    # holds all product classes
    mattr_accessor :product_classes
    self.product_classes = []


    
    module PropertyGroupsExtension
      
      # build property groups for given properties
      # if :properties is empty, the properties of the associated product are used
      # (given properties must be associated with product, otherwise an error is raised!)
      # :group specifies the group_by parameter (default = :type )
      # :limit specifies the needed size of the grouped properties array
      #
      # 
      # Example
      #   self.property_groups.build_for_properties( 
      #     :properties => [#<Color id:1>, #<Color id:2>, #<Size id:1>],
      #     :group => :type,
      #     :limit => 2 )
      #   # => [ #<PropertyGroup name:'Color', properties:[ #<Color id:1>, #<Color id:2> ] ]
      # 
      # 
      # if a property-groups exists (based on name = property.send( :type ) ), all associated properties of this group
      # are deleted and re-associated with the given properties (so the property-groups are always up-to-date).
      # all other exisiting property-groups (for which no given properties exist, or the :size doesnt match) are deleted.
      #
      def build_for_properties( opts = { :properties => proxy_owner.properties, :group => :type, :limit => 2 } )
        proxy_owner.properties.group_by(&opts[:group]).to_hash.each_pair do |klass,props|
          if props.size >= opts[:limit]
            group = proxy_owner.property_groups.find_by_name(klass) ||
              proxy_owner.property_groups.build( :name => klass, :selector => "select", :selector_text => "Please select ..." )
              
            group.properties.delete_all
            group.properties << props
          else
            group = proxy_owner.property_groups.find_by_name(klass)
            group.destroy if group
          end
          
        end
      end

    end

    class << self ;

      # save product extension modules
      def extend_product( *mods )
        self.product_extensions << mods
        self.product_extensions.flatten!
        self.product_extensions.uniq!
        
      end
      
      
      
      def included(base) #:nodoc:
        
        raise ArgumentError, "Can't include #{self} into more than one Product-Models. Use STI instead!" if
          self.included_in_classes.reject { |s| s == Opensteam::Product::Base }.size > 1
        
        Opensteam::Dependencies.set_product_model( base )
        
        
        base.class_eval do

          # hmt properties association
          has_many :products_properties, :class_name => "Opensteam::Product::ProductsProperty"
          has_many :properties, :through => :products_properties, :class_name => "Opensteam::Models::Properties"

          # hmt property_groups association
          has_many :property_groups, :extend => PropertyGroupsExtension
          has_many :properties_in_group, :through => :property_groups, :class_name => "Opensteam::Models::Properties"

          # hm inventories association
          has_many :inventories, :class_name => "Opensteam::Models::Inventory"

          # hm properties_through_ivnentories association
          has_many :properties_through_inventories, :class_name => "Opensteam::Models::Properties",
            :finder_sql => 'SELECT properties.* FROM properties ' +
            'INNER JOIN inventories_properties ON inventories_properties.property_id = properties.id ' +
            'INNER JOIN inventories ON inventories.id = inventories_properties.inventory_id ' +
            'WHERE ( inventories.product_id = #{id} )',
            :uniq => true

          validates_presence_of :name, :description
          validates_associated :property_groups

          alias :inventories_assoc :inventories

          # override inventories association method
          # if +p+ is not empty, returns all inventories with the given list of properties
          # if +p+ is empty, returns all associated inventories
          def inventories( p = [] )
            p.empty? ? self.inventories_assoc : self.inventories_assoc.by_properties( p )
          end

          attr_accessor :selected_inventory

        end

        base.send( :extend, ClassMethods )
        base.send( :include, InstanceMethods )

      end

    end


    module ClassMethods
      def inherited(sub) #:nodoc:
        super
        Opensteam::Product::Logic.product_classes << sub.to_s
        Opensteam::Product::Logic.product_classes.uniq!
      end

      # return all product classes # => String
      def product_classes
        Opensteam::Product::Logic.product_classes
      end


    end

    module InstanceMethods

      # return all property ids
      def property_ids
        self.properties.collect(&:id)
      end

      # set property ids
      def property_ids= ids 
        self.properties.delete_all
        self.properties << Property.find( ids )
      end

      # !! Deprecated !!
      # !! properties of property_groups must be present in @product.properties, so this method doesnt make sense !!
      def all_properties
        ( self.properties + self.property_groups.collect(&:properties ) ).flatten
      end


      # build properties for property_attributes
      #   @product.new_properties = [ { :name => "red", :type => "Color" }, { :name => "blue", :type => "Color" } ]
      #
      def new_properties= property_attributes
        property_attributes.each do |attributes|
          properties.build( attributes )
        end
      end


      # update existing properties andor delete properties not present in +property_attributes+ array
      def existing_properties= property_attributes
        all_properties.reject(&:new_record?).each do |property|
          attributes = property_attributes[ property.id.to_s ]
          if attributes
            property.attributes = attributes
          else
            properties.delete( property )
          end
        end
      end

      # save all associated properties without validations
      def save_properties
        properties.each { |property| property.save(false) }
      end



      # build inventories for given properties
      # +props+ must be an array of properties
      # if opts[:delete_all] = true, all associated properties are deleted, before building new ones
      # if no properties are given (empty array), only one inventory object is built
      #
      def build_inventory_for_properties props, opts = { :attributes => Inventory.default_attributes, :delete_all => false }
        opts[:attributes] ||= Inventory.default_attributes
        opts[:delete_all] ||= false
        props = Array(props) unless props.is_a?( Array )
        if props.empty?
          self.inventories.build( opts[:attributes] )
          return
        end

        if opts[:delete_all]
          # delete existing inventories for given properties
          existing_inventory = self.inventories.by_properties( Array(props) )
          existing_inventory.collect(&:destroy) unless existing_inventory.empty?
        end

        # build inventory item for given properties
        self.inventories.build( opts[:attributes].merge( :properties => props ) )
      end


    end

  end

    
end
