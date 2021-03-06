require 'lash'
require 'fileutils'
if Lash.lash_options[:use_sass]
  require 'sass'
  require 'sass/plugin'
  sass_config = File.join Rails.root, "/config/initializers/sass_config.rb"
  require sass_config if File.exists?(sass_config)
end
require 'rake/clean'


namespace :lash do
  desc 'Runs all lash tasks including javascripts and style sheets'
  task :all => [:js, :css]

  cdn_dirs = ['cdn']
  demand_dirs = ['demand']
  bundler = Lash::JavaScriptBundler.new :cdn_dirs => cdn_dirs, :demand_dirs => demand_dirs, :log => true
  
  @bin_path = File.expand_path( File.join( __FILE__, '../../../../bin' ) )
  
  javascripts_path = File.join( ::Rails.root, 'public', 'javascripts', '' )

  CLEAN.include( "#{javascripts_path}/**/bundle_*.js")
  CLEAN.include( "#{javascripts_path}/**/*.gz")
  CLEAN.include( "#{File.join ::Rails.root, 'public/stylesheets' }/**/*.gz")

  desc 'Bundles and minifies javascripts'
  task :js => [:js_bundle, :js_min]
  
  # Creates an application.bundleVersion.js file
  task :js_bundle_version do
    target = File.join( Rails.root, "public/javascripts/application" )
    if File.exist? target
      asset_id = Lash::AssetsHost.asset_id( target )
      File.open( File.join( target, "application.bundleVersion.js" ), "w+" ) { |f| f.write "window.bundleVersion = '#{asset_id}';"}
    end
  end
  
  desc 'Bundles javascripts folders into single minified files'
  task :js_bundle => [:js_bundle_version] do    
    Lash::Files.get_top_level_directories( javascripts_path ).each do |bundle_directory|
      next unless bundler.bundle_style( bundle_directory ) == :single
      bundler.bundle bundle_directory, :log => true
    end
  end 
  
  desc 'Minifies all loose javascripts'
  task :js_min => [:js_bundle_version] do
    Lash::Files.get_top_level_directories( javascripts_path ).each do |bundle_directory|
      next unless bundler.bundle_style( bundle_directory ) == :individual
      bundler.bundle bundle_directory
    end
  end
  
  desc 'Compresses all javascripts for nginx gzip_static support'
  task :js_gzip do |t|
    Dir[ File.join Rails.root, 'public/javascripts/**/*.js' ].each do |file|
      next unless bundler.bundle_style( File.dirname( file ) ) == :individual
      %x{gzip -c -9 "#{file}" > "#{file}.gz" }
    end
  end
  
  desc 'Generate CSS sprites from the public/sprites folders'
  task :sprites do |t|
    sprites_folder = File.join( Rails.root, "public/sprites" )
    if File.exist? sprites_folder
      sprite_bundler = Lash::SpriteBundler.new
      Lash::Files.get_top_level_directories( sprites_folder ).each do |bundle_directory|
        sprite_bundler.bundle bundle_directory, :log => true
      end
    end
  end
  
  desc 'Pre-generate sass scripts' if Lash.lash_options[:use_sass]
  task :sass do |t|
    if Lash.lash_options[:use_sass]
      sass_target = File.join( Rails.root, "public/stylesheets/sass" )
      if File.exist? sass_target
        asset_id = Lash::AssetsHost.asset_id( sass_target ) 
        File.open( File.join( sass_target, "_version.scss" ), "w+" ) { |f| f.write "$bundle-version: '#{asset_id}';"}
      end
      
      Sass::Plugin.force_update_stylesheets
    end
  end
  
  desc "Compresses stylesheets for use with nginx gzip_static"
  task :css_gzip do |t|
    Dir[ File.join Rails.root, 'public/stylesheets/*.css' ].each do |file|
      %x{gzip -c -9 "#{file}" > "#{file}.gz" }
    end
  end
  
  desc 'Process CSS scripts'
  task :css => [:sprites, :sass, :css_gzip, :png] do |t|
  end
  
  desc 'Optimizes all PNG images in the public/images folder'
  task :png do |t|
    Lash::Files.recursive_file_list( File.join( Rails.root, "public/images" ), ".png" ).each do |p|
      `#{File.expand_path ::File.join( __FILE__, '../../../../bin/optipng')} -o7 \"#{p}\"`
      abort "Failed to optimize png #{p}, status = #{$?.exitstatus}" unless $?.exitstatus == 0
    end
  end  

  desc 'Called by capistrano to generate static assets on the server'
  task :deploy => [:js, :css, :png] do
  end
end
