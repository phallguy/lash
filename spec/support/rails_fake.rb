require 'rspec'
require 'rspec/mocks'

class RailsFake
  attr_accessor :env
  attr_accessor :root
  
  def initialize
    @env = RSpec::Mocks::Mock.new
  end  
  
  def env=(s)
    %w{ production development test }.each do |e|
      @env.stub("#{e}?").and_return( e == s.to_s )    
    end
  end
  
end

class String
  def html_safe
    self
  end
  
  def parameterize
    self
  end
end


::Rails = ::RailsFake.new
