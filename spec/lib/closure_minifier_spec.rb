require File.expand_path( '../../spec_helper', __FILE__ )
require 'lash/lash_files'
require 'lash/closure_minifier'

describe Lash::ClosureMinifier do
  
  before :each do
    @minifier = Lash::ClosureMinifier.new
    @target = File.join( TMP_ROOT, 'tmp.js' ) 
    @application_scripts = Lash::Files.recursive_file_list( File.join( JAVASCRIPTS_ROOT, 'application' ), 'js' )
    
    File.delete @target if File.exist? @target
    File.delete "#{@target}.gz" if File.exist? "#{@target}.gz"

    @result = @minifier.minify( @application_scripts, @target )
  end
  
  it "should not fail" do
    @result.should be_true
  end
  
  it "should minify to target folder" do
    File.exist?( @target ).should be_true
  end
  
  it "should be smaller than the original files" do
    size = @application_scripts.inject(0) { |n,s| n = n + File.size( s ) }
    File.size( @target ).should < size
  end

  it "should not be zero length file" do
    File.size( @target ).should > 0
  end
  
  it "should create a gzippped companion file" do
    File.exist?(@target + '.gz').should be_true
  end

  it "should join compiler options" do
    @minifier.options = {
      :one => "1",
      "--open" => "two",
      "--on" => nil
    }
    
    @minifier.send( :compiler_options ).should == "one 1 --open two --on"
  end

  it "should fail when it contains invalid javascript" do
    invalid = File.join( TMP_ROOT, "invalid.js" ) 
    File.open( invalid, "w+" ) do |f|
      f.write( "I don't make any sense")
    end
    
    @application_scripts << invalid
    @minifier.minify( @application_scripts, @target ).should be_false
  end
  
end