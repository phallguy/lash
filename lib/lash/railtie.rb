require 'lash'
require 'rails'
require 'grit'

module Lash
  class Railtie < Rails::Railtie

    rake_tasks do
      load "lash/tasks/lash.rake"
    end

    initializer "lash.active_view" do |app|
      require 'lash/bundle_helper'
      ActionView::Base.send( :include, Lash::BundleHelper )
    end
    
    initializer "lash.setup_git_asset_id", :before => "action_controller.set_configs" do |app|
      repo = Grit::Repo.new( Rails.root.to_s )

      ENV['RAILS_ASSET_ID'] = \
      [:javascripts, :stylesheets, :images] \
        .map { |folder| repo.log( 'master', "public/#{folder}", :max_count => 1 ).first } \
        .max_by { |log| log.committed_date }
        .id

      app.config.action_controller.asset_host = Proc.new do |source,request|
        if /\/\// =~ source
          nil
        elsif request.ssl? and ! Lash.lash_options[:use_asset_servers_in_ssl]
          nil
        elsif !Lash.lash_options[:use_asset_servers]
          nil
        else

          # Change the host name to include a randomized asset name at the same domain
          # level. This is required so that HTTPS requests can use a wildcard domain
          # without using subject alt name.

          host = request.host_with_port
          parts = host.split( /\./ )
          if parts.length > 2 
            parts[0] = "#{parts[0]}-assets#{source.hash % 4}"
          else
            parts.unshift "assets#{source.hash % 4}"
          end

          "http#{'s' if request.ssl?}://#{parts.join('.')}"
        end
      end
    end
    
  end
end