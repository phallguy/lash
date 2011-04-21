require 'grit'
require 'lash'

module Lash
  module AssetsHost    
    
    # Configures Rails to use the most recent GIT repo id for public/(javascripts|stylesheets|images) for the
    # asset id used for cache busting.
    def self.use_git_asset_id
      return unless Lash.lash_options[:use_git_asset_id]

      repo = Grit::Repo.new( Rails.root.to_s )

      ENV['RAILS_ASSET_ID'] = \
      [:javascripts, :stylesheets, :images] \
        .map { |folder| repo.log( 'master', "public/#{folder}", :max_count => 1 ).first } \
        .max_by { |log| log && log.committed_date } 
        .id
    end
    
    # Generates an asset id for the given file used for cache-busting
    def self.asset_id( file )
      if Lash.lash_options[:use_git_asset_id]
        repo = Grit::Repo.new( Rails.root.to_s )
        [:javascripts, :stylesheets, :images] \
          .map { |folder| repo.log( 'master', "public/#{folder}", :max_count => 1 ).first } \
          .max_by { |log| log && log.committed_date } 
          .id
      elsif ::File.exist?( file )
        File.mtime( file ).to_i.to_s
      end
    end
    
    # Method used to map an asset to a static asset server. This method simply generates a semi-random domain
    # prefix based on the filename of the source. The asset server should resolve to the same server as
    # the rails app. This is a basic browser hack to allow more than 4 connections to the server so that the
    # browser can download multiple assets simultaneously.
    #   
    # @example 
    #     request.host        # => lvh.me
    #     resolve_static_asset_server_for_source "smiles", request
    #                         # => assets1.lvh.me      
    #
    #     # from terminal
    #     nslookup lvh.me           # => 127.0.0.1
    #     nslookup assets1.lvh.me   # => 127.0.0.1
    
    def self.resolve_static_asset_server_for_source( source, request )
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