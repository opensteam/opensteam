class Category < ActiveRecord::Base
  self.include_root_in_json = false if Category.respond_to?(:include_root_in_json)

  has_many :categories_inventories
  has_many :inventories, :through => :categories_inventories

  # returns all assigned inventories with preloading associated products
  def inventories_includes_products
    returning( self.inventories ) do |i|
      self.class.send( :preload_associations, i, :product )
    end
  end

  # returns all assigned products through inventories (uniq)
  def products
    self.inventories_includes_products.collect(&:product).uniq
  end



  # assign inventories of products to category. deletes existing first
  # parameter must be a hash, like:
  #
  # { "ProductModel" => ["1","2","3"] }
  #
  def products= (p)
    return nil unless p.is_a?( Hash )

    self.inventories.delete_all

    transaction do

      self.inventories << p.collect { |prod|
        prod.first.classify.constantize.find( prod.last, :include => :inventories ).collect(&:inventories)
      }.flatten.uniq

    end

  end

  def push_products(p)
    self.inventories << p.collect(&:inventories).flatten.uniq
  end




  ### nested-set specific methods ####
  ###
  #  acts_as_nested_set :parent_column => :parent_id,
  #    :left_column => 'lft_id',
  #    :right_column => 'rgt_id'

  acts_as_tree :order => "name"

  named_scope :root_nodes, { :conditions => 'parent_id IS NULL' }

  class << self ;
    def find_children( id = nil )
      id.to_i == 0 ? root_nodes.first.full_set : find( id ).children
    end

    def root_nodes_hash( product = nil )
      return root_nodes.collect(&:to_hash) unless product
      return root_nodes.collect { |c| c.to_hash( product ) }
    end

  end

  def leaf ; false ; end

  def text ; "#{name} (#{children_count})"; end

  def href ; "/admin/catalog/categories/#{self.id}/edit" ; end

  def checked ; false ; end

  def children_count ; self.children.size ; end

  def to_hash( product = nil )
    h = { :text => "#{self.name} (#{self.children_count})",
      :id => self.id,
      :href => href,
      :expanded => true,
      :leaf => false,
      :iconCls => 'tree-folder-icon'
    }

    unless product
      return h.merge( :children => self.children.size > 0 ? children.collect(&:to_hash) : [] )
    else
      h.merge(
        :children => self.children.size > 0 ? children.collect { |c| c.to_hash(product) } : [],
        :checked => product.categories.include?( self )
      ) ;
    end

  end


  def self_and_ancestors
    [ self, self.ancestors ].flatten.reverse
  end

  # returns the path of the current node
  def path(method = :id, str = "/" )
    "#{str}0#{str}" + self_and_ancestors.collect(&method).join(str)
  end

  def to_json_with_leaf( options = {} )
    self.to_json_without_leaf( options.merge( :methods => [:leaf, :text, :href] ) )
  end

  alias_method_chain :to_json, :leaf

end





module InventoryCategory
  def self.included(base)
    base.class_eval do
      has_many :categories_inventories
      has_many :categories, :through => :categories_inventories
    end
  end
end


module ProductCategory
  def categories
    self.inventories.collect(&:categories).flatten.uniq
  end

  def categories_ids
    self.categories.collect(&:id).join(",")
  end


  def categories_ids=(i)
    self.inventories.collect(&:categories).collect(&:delete_all)
    i.split(',').each do |category_id|
      Category.find( category_id ).inventories << self.inventories
    end
  end

end

Opensteam::ProductBase.extend_product( ProductCategory )
Opensteam::Models::Inventory.send( :include, InventoryCategory )

