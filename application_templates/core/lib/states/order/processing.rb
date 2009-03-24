module Opensteam::Sales::OrderBase::States::Processing

  include Opensteam::StateLogic::Mod
  
  
  
  protected
  def process!
    puts "now in processing ..."
  end
end