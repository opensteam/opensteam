# borrowed from http://blog.evanweaver.com/articles/2007/03/28/dependency-injection-for-rails-models/

module ActiveSupport::Dependencies
  mattr_accessor :injection_graph
  self.injection_graph = Hash.new([])

  def inject_dependency(target, *requirements)
    puts target
    puts requirements.inspect
    target, requirements = target.to_s, requirements.map(&:to_s)    
    injection_graph[target] = 
      ((injection_graph[target] + requirements).uniq - [target])
    requirements.each {|requirement| mark_for_unload requirement }
  end

  def new_constants_in_with_injection(*descs, &block)
    returning(new_constants_in_without_injection(*descs, &block)) do |found|
      found.each do |constant|
        injection_graph[constant].each {|req| req.constantize}
      end    
    end
  end
  alias_method_chain :new_constants_in, :injection   
end

