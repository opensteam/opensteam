class Category < ActiveRecord::Base

  has_many :categories_products
  has_many :products, :through => :categories_products

  acts_as_tree :order => "name"
  named_scope :root_nodes, { :conditions => 'parent_id IS NULL', :include => :products }
  named_scope :active, { :conditions => { :active => true } }

  class << self ;
    def find_children( id = nil )
      id.to_i == 0 ? root_nodes.first.full_set : find( id ).children
    end

    def root_nodes_hash( product = nil )
      return root_nodes.collect(&:to_hash) unless product
      return root_nodes.collect { |c| c.to_hash( product ) }
    end

  end

  def children_count ; self.children.size ; end

  def product_ids=(params)
    self.products.delete_all
    self.products << Product.find( params )
  end
  

  def self_and_ancestors
    [ self, self.ancestors ].flatten.reverse
  end

  # returns the path of the current node
  def path(method = :id, str = "/" )
    "#{str}0#{str}" + self_and_ancestors.collect(&method).join(str)
  end
  
  def to_hash( product = nil )
    returning({}) do |h|
      h[:text] = "#{self.name} (#{self.children_count})"
      h[:id] = self.id
      h[:href] = "/admin/catalog/categories/#{self.id}"
      h[:expanded] = true,
      h[:leaf] = false
      h[:iconCls] = 'tree-folder-icon'
      
      h[:children] = self.children.size > 0 ? self.children.collect { |ch| ch.to_hash( product ) } : []
      h[:checked] = product.categories.include?( self ) if product
    end
  end
  
  
end



