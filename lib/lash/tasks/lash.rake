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
  
  desc 'Bundles javascripts folders into single minified files'
  task :js_bundle do    
    Lash::Files.get_top_level_directories( javascripts_path ).each do |bundle_directory|
      next unless bundler.bundle_style( bundle_directory ) == :single
      bundler.bundle bundle_directory, :log => true
    end
  end 
  
  desc 'Minifies all loose javascripts'
  task :js_min do
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
  
  desc 'Pre-generate sass scripts'
  task :sass do |t|
    puts "SASS env = #{Rails.env} / #{Sass::Plugin.options[:style]}"
    Sass::Plugin.force_update_stylesheets
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
  task :deploy => [:sass, :gzip_css, :js_gzip] do
  end
end
