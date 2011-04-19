require File.expand_path( '../../spec_helper.rb', __FILE__ )
require 'lash/assets_host'

describe Lash::AssetsHost do
  
  
  context "asset_id" do
    it "should use the git repo hash for the cachebusting id" do 
      Rails.root = File.expand_path( "../../../", __FILE__ )
      Lash::AssetsHost.use_git_asset_id
      ENV['RAILS_ASSET_ID'].should match /\A[a-f0-9]{40}\Z/
    end
  end
  
  context "static assets server" do
    before :each do
      Lash.lash_options[:use_asset_servers] = true
      @request = mock()
      @request.stub("ssl?").and_return(false)
      @request.stub("host_with_port").and_return("lvh.me")
    end
    
    
    it "should prepend and assets subdomain" do
      Lash::AssetsHost.resolve_static_asset_server_for_source( "pickles", @request ) \
        .should match %r{http://assets\d\.lvh\.me}
    end
    
    it "should return nil when disabled" do
      Lash.lash_options[:use_asset_servers] = false
      Lash::AssetsHost.resolve_static_asset_server_for_source( "poodles", @request ) \
        .should be_nil
    end
    
    it "should use https protocol in ssl" do
      @request.stub("ssl?").and_return(true)
      Lash::AssetsHost.resolve_static_asset_server_for_source( "aligators", @request ) \
      .should match %r{\Ahttps://}
    end

    it "should return nil in ssl when disabled " do
      @request.stub("ssl?").and_return(true)
      Lash.lash_options[:use_asset_servers_in_ssl] = false
      Lash::AssetsHost.resolve_static_asset_server_for_source( "aligators", @request ) \
      .should be_nil
    end
    
    it "should modify subdomain when more than 2 parts" do
      @request.stub("host_with_port").and_return("mickey.mouse.com")
      Lash::AssetsHost.resolve_static_asset_server_for_source( "pickles", @request ) \
        .should match %r{http://mickey-assets\d\.mouse\.com}
    end    
    
  end
  
end