require File.expand_path( '../../spec_helper.rb', __FILE__ )
require 'lash/files'
require 'lash/java_script_minifier'
require 'lash/java_script_bundler'


class SimpleMinifier < Lash::JavaScriptMinifier
end

describe Lash::JavaScriptBundler do
  
  before :each do
    Rails.root = RAILS_ROOT
    @bundler = Lash::JavaScriptBundler.new( :minifiers => SimpleMinifier.new )
  end
  
  it "should bundle into a single file :style => :single" do
    @bundler.stub(:migrate_best_target)
    @bundler.should_receive( :bundle_scripts_with_minifier ).once \
        .and_return { |f| File.open( f.first + '.tmp', "w+" ) { |s| s.write( f ) }; "#{f.first}.tmp" }
    @bundler.bundle 'application', :style => :single
  end
  
  it "should bundle individual files when :style => :individual" do
    @bundler.stub(:migrate_best_target)
    @bundler.should_receive( :bundle_scripts_with_minifier ).at_least(3).times \
        .and_return { |f| File.open( f.first + '.tmp', "w+" ) { |s| s.write( f ) }; "#{f.first}.tmp" }
    @bundler.bundle 'application', :style => :individual
  end
  
  it "should use single style for directories that are not included in cdn_dirs and demand_dirs" do
    @bundler.should_receive(:bundle_into_single_script)
    @bundler.bundle "application"    
  end

  it "should use individual style for directories that are not included in cdn_dirs" do
    @bundler.should_receive(:bundle_individual_scripts)
    @bundler.bundle "cdn"
  end

  it "should use individual style for directories that are not included in demand_dirs" do
    @bundler.should_receive(:bundle_individual_scripts)
    @bundler.bundle "demand"
  end
  
end