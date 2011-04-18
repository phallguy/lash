require File.expand_path( '../../spec_helper.rb', __FILE__ )
require 'lash/assets_host'

describe Lash::AssetsHost do
  it "should use the git repo hash for the cachebusting id" do 
    Rails.root = File.expand_path( "../../../", __FILE__ )
    Lash::AssetsHost.use_git_asset_id
    ENV['RAILS_ASSET_ID'].should match /[a-f0-9]{32}/
  end
end