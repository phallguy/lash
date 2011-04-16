require 'lash-sprites/sprite'
require 'lash-sprites/css'
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
  minify_dirs = ['demand']
  @bin_path = File.expand_path( File.join( __FILE__, '../../../../bin' ) )
  
  exclude_dirs = cdn_dirs + minify_dirs

  javascripts_path = File.join( ::Rails.root, 'public', 'javascripts', '' )
  CLEAN.include( "#{javascripts_path}/**/*.gz")
  CLEAN.include( "#{File.join ::Rails.root, 'public/stylesheets' }/**/*.gz")

  desc 'Bundles and minifies javascripts'
  task :js => [:js_bundle, :js_min]
  
  desc 'Bundles javascripts folders into single minified files'
  task :js_bundle do    
    
    paths = get_top_level_directories( javascripts_path )
    paths.each do |bundle_directory|
      bundle_name = bundle_directory.gsub( javascripts_path, "")
      
      next if exclude_dirs.include? bundle_name
      
      files = recursive_file_list( bundle_directory, ".js" )
      next if files.empty?
      
      target = File.join( javascripts_path, "bundle_#{bundle_name}.js" )
      
      compile_js files, target
    end
  end 
  
  desc 'Minifies all javascripts'
  task :js_min do
            
    paths = get_top_level_directories( javascripts_path )
    
    paths.each do |bundle_directory|
      bundle_name = bundle_directory.gsub( javascripts_path, "")
      next unless minify_dirs.include? bundle_name
      
      recursive_file_list(bundle_directory,'.js').reject{|f| f =~ /\.min\.js$/}.each do |file|
        compile_js( [file], 
                    file.gsub( /.js$/, ".min.js" ) )
      end
    end
  end
  
  desc 'Compresses minified javascripts for nginx gzip_static support'
  task :js_gzip do |t|
    Dir[ File.join Rails.root, 'public/javascripts/**/*.js' ].each do |file|
      %x{gzip -c -9 "#{file}" > "#{file}.gz" }
    end
  end
  
  def compile_js(files,target)
    
    tmp_file = File.join( Rails.root, 'tmp', File.basename( target, '.js' ) );
    packs = []
    
    %W{ closure }.each do |packer|
      packs << pack = { 
        :file => "#{tmp_file}_#{packer}",
      }
            
      self.send "compile_js_#{packer}", files, pack[:file]
      %x{gzip -c -9 "#{pack[:file]}" > "#{pack[:file]}.gz" }
      pack[:size] = File.size "#{pack[:file]}.gz"
    end
    
    smallest = packs.min{ |a,b| a[:size] <=> b[:size] }[:file]
    
    FileUtils.cp smallest, target
    FileUtils.cp "#{smallest}.gz", "#{target}.gz"
    puts "=> bundled js at #{target}"

  ensure
    packs.each { |pack| 
      File.delete pack[:file] if File.exist? pack[:file] 
      File.delete "#{pack[:file]}.gz" if File.exist? "#{pack[:file]}.gz"
      }
  end
  
  
  
  def compile_js_closure(files,target)
    closure_path = File.join( @bin_path, 'closure-compiler/compiler.jar' )
    `java -jar \"#{closure_path}\" --warning_level QUIET --js \"#{files.join("\" --js \"")}\" --js_output_file \"#{target}\"`
    abort "Could not minify files #{files.join(", ")}" unless $?.exitstatus
  end

  desc 'Generate CSS sprites from the public/sprites folders'
  task :css_sprites do |t|
    
    Dir[  'public/sprites/*' ].select{ |d| File.directory? d }.each do |sprite_dir|
      
      sprite_name   = ( File.basename( sprite_dir ) + '-sprite' ).gsub(' ', '-')
      css_file      = File.join( 'public/stylesheets/sass/', "_#{sprite_name}.scss" )
      sprite_files  = FileList[ File.join( sprite_dir, '*.*' ) ].exclude(/.*\.css$/)

      sprite_file   = "public/images/#{sprite_name}.png";
      FileUtils.rm_rf( File.join( Rails.root, sprite_file ) )

      sprite = RubySprites::Sprite.new( "public/images/#{sprite_name}.png", 
                                        Rails.root, 
                                        :graphics_manager => :rmagick,
                                        :pack_type => 'both_smart' )
      
      sprite_files.each do |f|
        sprite.add_image( f )
      end

      sprite.update
      generate_css( sprite, File.basename( sprite_dir ), css_file, sprite_dir )      
      
      puts "=> bundled css at #{css_file}"
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
  task :css => [:css_sprites, :sass, :css_gzip] do |t|

  end
  
  
  def load_css_template(sprite_dir, template_name)
    css_template_file = File.join( sprite_dir, template_name );
    return IO.read(css_template_file) if File.exists? css_template_file
    nil
  end

  def generate_css(sprite,class_name,file,sprite_dir)

    # Calculate most common width and height so sprites can default
    width_freq, height_freq = {}, {}

    sprite.images.each do |path,image|
      next unless image.width and image.height
      
      width_freq[image.width] = ( width_freq[image.width] || 0 ) + 1
      height_freq[image.height] = ( height_freq[image.height] || 0 ) + 1
    end
    
    width = width_freq.max_by { |e| e[1] }[0]
    height = height_freq.max_by { |e| e[1] }[0]
    

    png_file = sprite.filename[6,sprite.filename.size-6]
    css = eval ( load_css_template( sprite_dir, "template.css" ) ||
    '"
.#{class_name}-background { 
  	background-image: url(..#{png_file}?#{Date.new.to_time.to_i}); 
  	background-repeat: no-repeat;
}

.#{class_name} { 
	background-color: transparent;
	background-image: url(..#{png_file}?#{Date.new.to_time.to_i}); 
	background-repeat: no-repeat;
	overflow: hidden;
  text-indent: 99999px;
  *text-indent: 999px; // IE 7 fix
  text-align: left!important;
  width: #{width}px;
  height: #{height}px;
}

"' )

    css_sprite_template = load_css_template( sprite_dir, "sprite-template.css" ) || '
      ".#{class_name}-#{name} { background-position: -#{image.x}px -#{image.y}px;#{ "width: #{image.width}px; " if image.width != width }#{ "height: #{image.height}px; " if image.height != height } }\n" 
    '

    sprite.images.each do |path, image|
      name = File.basename(path)
      name = name[ 0, name.rindex( '.' ) ].gsub( '/', '-' )
      css += eval css_sprite_template
    end

    fp = File.open( sprite.file_root + file, 'w' )
    fp.write( css )
    fp.close

    `#{File.join( @bin_path, 'optipng')} -o7 \"#{sprite.filename}\"` if File.exists? sprite.filename
  end
    
  
  require 'find'
  def recursive_file_list(basedir, ext)
    files = []
    Find.find( basedir ) do |path|
      if FileTest.directory?( path )
        if File.basename( path )[0] == ?. # Skip dot directories
          Find.prune
        else
          next
        end
      end
      files << path if File.extname( path ) == ext
    end
    files.sort
  end

  def get_top_level_directories( base_path )
    Dir.entries( base_path ).collect do |path|
      path = File.join( base_path, path )
      File.basename( path )[0] == ?. || !File.directory?( path ) ? nil : path # not dot directories or files
    end - [nil]
  end
  
  desc 'Called by capistrano to generate static assets on the server'
  task :deploy => [:sass, :gzip_css, :js_gzip] do
  end
end
