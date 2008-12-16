mailer_path = File.join( "#{RAILS_ROOT}", "app", "models", "mailer", "*mailer*" ) ;
if ActiveRecord::Base.connection.tables.include?( "config_mails")
  Dir.glob( mailer_path ).each do |mp|
    file = "Mailer::" + File.basename( mp, '.rb' ).classify
    file.constantize.instance_methods(false).each do |m|
      Opensteam::System::Mailer.find_or_create_by_mailer_class_and_mailer_method( :mailer_class => file, :mailer_method => m, :active => true )
    end
  end
end 


class ActionMailer::Base

  def deliver_with_active_mailer_check!(mail = @mail )
    active_mailer = Opensteam::System::Mailer.mailer_class( self.class.to_s ).mailer_method( @template ).active
    return nil if active_mailer.empty?
    ret = deliver_without_active_mailer_check!(mail)
    active_mailer.collect(&:increment_messages)
    ret
  end

  alias_method_chain :deliver!, :active_mailer_check

end
class Array
  def to_ext_xml options = {}
    raise "Not all elements respond to to_xml" unless all? { |e| e.respond_to? :to_xml }
    
    options[:indent] ||= 2
    options[:builder] ||= Builder::XmlMarkup.new( :indent => options[:indent] )
    options[:builder].instruct! unless options.delete( :skip_instruct )

    opts = options.merge( { :skip_instruct => true, :root => "Item" } )

    options[:builder].tag!( "Items") {
      options[:builder].tag!( "type", self.first.class.to_s.demodulize.tableize )
      options[:builder].tag!( "TotalResults", options[:total_entries] )
      options[:builder].Request { options[:builder].tag!( "IsValid", true ) }
      each { |e| e.to_ext_xml( opts ) }
    }

  end
end
