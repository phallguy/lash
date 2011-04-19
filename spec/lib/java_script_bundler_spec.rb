require File.expand_path( '../../spec_helper.rb', __FILE__ )
require 'lash/files'
require 'lash/java_script_minifier'
require 'lash/java_script_bundler'


class SimpleMinifier < Lash::JavaScriptMinifier
end

describe Lash::JavaScriptBundler do
  
  before :each do
    @bundler = Lash::JavaScriptBundler.new( SimpleMinifier.new )
  end
  
  it "should bundle all the files"
  
  
end