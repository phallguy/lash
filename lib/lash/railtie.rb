require 'lash'
require 'lash/assets_host'
require 'rails'

module Lash
  # Adds Lash helper methods to your rails application. See {Lash::AssetsHost} for more details.
  class Railtie < Rails::Railtie

    rake_tasks do
      load "lash/tasks/lash.rake"
    end

    initializer "lash.active_view" do |app|
      require 'lash/bundle_helper'
      ActionView::Base.send( :include, Lash::BundleHelper )
    end
    
    initializer "lash.setup_git_asset_id", :before => "action_controller.set_configs" do |app|
      Lash::AssetsHost.use_git_asset_id      
      app.config.action_controller.asset_host = Proc.new{ |source,request| Lash::AssetsHost.resolve_static_asset_server_for_source( source, request ) }
    end
    
  end
end