require 'grit'
require 'lash'

module Lash
  module AssetsHost    
    
    def self.use_git_asset_id
      return unless Lash.lash_options[:use_git_asset_id]

      repo = Grit::Repo.new( Rails.root.to_s )

      ENV['RAILS_ASSET_ID'] = \
      [:javascripts, :stylesheets, :images] \
        .map { |folder| repo.log( 'master', "#{Rails.root}/public/#{folder}", :max_count => 1 ).first } \
        .max_by { |log| log && log.committed_date } 
        .id
    end
    
    def self.static_asset_servers( source, request )
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