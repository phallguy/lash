$:.unshift File.join( File.dirname( __FILE__ ), 'support' )

require 'lash'

PUBLIC_ROOT = File.expand_path( '../test_app/public/', __FILE__ )
JAVASCRIPTS_ROOT = File.join( PUBLIC_ROOT, 'javascripts' )
STYLESHEETS_ROOT = File.join( PUBLIC_ROOT, 'stylesheets' )
IMAGES_ROOT = File.join( PUBLIC_ROOT, 'images' )

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f} 

RSpec.configure do |c|
  c.filter_run :focus => true
  c.run_all_when_everything_filtered = true
end