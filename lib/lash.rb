module Lash
  # Options for bundle helpers are optional and get their default values
  # from the Lash::ViewHelpers.lash_options hash. You can write
  # to this hash to override default options on the global level:
  #
  #     Lash.lash_options[:unicorns] = 'run free'
  #
  def self.lash_options() @lash_options; end

  # Overrides the default {lash_options}
  #
  # @option options [String] :use_asset_servers           Use asset server subdomain hack to allow multiple simultaenous connections. See {Lash::AssetsHost.resolve_static_asset_server_for_source}.
  # @option options [String] :use_asset_servers_in_ssl    Use asset server subdomain hack even over SSL. Requires a wildcard certificate.
  # @option options [String] :use_sass                    Support SASS 
  # @option options [String] :use_git_asset_id            Use GIT repro id for cachebusting asset id
  # @option options [String] :closure_compiler            Path to custom version of google's closure compiler.
  def self.lash_options=(options) @lash_options = options; end
  
  self.lash_options = {
    :use_asset_servers            => true,
    :use_asset_servers_in_ssl     => true,
    :use_sass                     => Gem.available?('sass'),
    :use_git_asset_id             => true,
    :closure_compiler             => File.expand_path( "../../bin/closure-compiler/compiler.jar", __FILE__ )
  }
end

require 'lash/railtie' if defined?(Rails) && Rails === Class and defined?(::Rails::Railtie)
require 'lash/java_script_bundler'
require 'lash/sprite_bundler'
require 'lash/files'