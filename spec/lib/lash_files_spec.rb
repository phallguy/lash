require File.expand_path( '../../spec_helper.rb', __FILE__ )
require 'lash/lash_files'

describe Lash::Files do

  context "recursive_file_list" do 
  
    it "should find files with extension including a leading period" do
      Lash::Files.recursive_file_list( File.join( JAVASCRIPTS_ROOT, 'application' ), '.js' ) \
        .count.should > 0
    end
  
    it "should find files with extension without a leading period" do
      Lash::Files.recursive_file_list( File.join( JAVASCRIPTS_ROOT, 'application' ), 'js' ) \
        .count.should > 0
    end
  
    it "should find files without an extension" do
      Lash::Files.recursive_file_list( File.join( JAVASCRIPTS_ROOT, 'application' ), nil ) \
        .count.should > 0
    end
  
    context "javascripts/application" do
    
      before :each do
        @files = Lash::Files.recursive_file_list File.join( JAVASCRIPTS_ROOT, 'application' ), '.js'
      end
    
      it "should find exactly 3 files" do
        @files.count.should == 3
      end
    
      it "should include all files in application folder" do
        %w{ application.js application2.js tools/validate.js }.each do |f|
          @files.should include( File.join( JAVASCRIPTS_ROOT, 'application', f ) )
        end
      end    
    
      it "should not include README" do
        %w{ README }.each do |f|
          @files.should_not include( File.join( JAVASCRIPTS_ROOT, 'application', f ) )
        end
      end
    end
  end
  
  context "get_top_level_directories" do
    
    before :each do
      @dirs = Lash::Files.get_top_level_directories( JAVASCRIPTS_ROOT )
    end
    
    it "should find application, cdn, demand" do
      %w{ application cdn demand }.each do |f|
        @dirs.should include( File.join( JAVASCRIPTS_ROOT, f ) )
      end
    end
    
    it "should not find application/tools" do
      %w{ application/tools }.each do |f|
        @dirs.should_not include( File.join( JAVASCRIPTS_ROOT, f ) )
      end
      
    end
    
  end

 end