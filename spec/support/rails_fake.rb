require 'rspec'

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

::Rails = ::RailsFake.new
