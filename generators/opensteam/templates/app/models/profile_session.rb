class ProfileSession
  
  
  def initialize( sess )
    @session_ = sess
    @session_[:active_filter] ||= {}
  end
  
  
  def [](controller)
    @session_[ controller.class.to_s ] ||= ControllerSession.new
  end
  
  def []=(controller,h)
    if sc = @session[_controller.class.to_s ]
      sc.set(h)
    else
      sc = ControllerSession.new( h )
    end
  end
  
  
  class ControllerSession
    attr_accessor :page, :per_page, :sort, :dir, :filter
    
    def initialize h = {}
      @page = h[:page] || 1
      @per_page = h[:per_page] || 20
      @dir = h[:dir] || 'asc'
      @sort = h[:sort] || 'id'
    end
    
    def set h
      @page = h[:page]
      @per_page = h[:per_page]
      @dir = h[:dir]
      @sort = h[:sort]
    end
  end
  
  
  
  def save_filter( controller, ids)

    ids ||= {}
    ids[:existing_filter] ||= {}
    ids[:new_filter] ||= []

    active_filter( controller ).each do |i|
      attributes = ids[:existing_filter][ i.to_s ]
      if attributes
        f = Opensteam::Helpers::Grid::FilterEntry.find( i )
        f.update_attributes( attributes ) if f
      else
        f = Opensteam::Helpers::Grid::FilterEntry.find( i )
        f.destroy if f
        active_filter( controller ).delete( i )
      end
    end

    ids["new_filter"] ||= []
    b = ids["new_filter"].collect { |f| Opensteam::Helpers::Grid::FilterEntry.create( f ).id }
    puts "**" * 10
    puts b
    
    active_filter( controller ).push( *b )

  end

  def delete_all_filter( controller )
    @session_[:active_filter][ controller.class.to_s ] = []
  end

  def active_filter( controller )
    @session_[:active_filter][ controller.class.to_s ] ||= []
  end
  
  def save_sorting controller, h = {}
    @session_[:sorting][controller.class.to_s] = h
  end
  
  def save_paging controller, h = {}
    @session_[:paging][controller.class.to_s] = h
  end
  
  def current_sort controller
    @session_[:sorting][ controller.class.to_s ][:sort]
  end
  
  def current_sort_dir controller
    @session_[:sorting][ controller.class.to_s ][:dir]
  end
  
  def current_page controller
    @session_[:paging][ controller.class.to_s][:page]
  end
  
  def current_per_page controller
    @session[:paging][ controller.class.to_s][:per_page]
  end
  
  
  
        
end

  