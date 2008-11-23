class ProfileSession
  
  
  def initialize( sess )
    @session_ = sess
    @session_[:active_filter] ||= {}
  end
  
  def save_filter( controller, ids)
    puts ")))))" * 100 ;

    ids ||= {}
    ids[:existing_filter] ||= {}
    ids[:new_filter] ||= []

    active_filter( controller ).each do |i|
      attributes = ids[:existing_filter][ i.to_s ]
      if attributes
        f = Opensteam::System::FilterEntry.find( i )
        f.update_attributes( attributes ) if f
      else
        f = Opensteam::System::FilterEntry.find( i )
        f.destroy if f
        active_filter( controller ).delete( i )
      end
    end

    ids["new_filter"] ||= []
    b = ids["new_filter"].collect { |f| Opensteam::System::FilterEntry.create( f ).id }
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
        
end

  