require 'lash'
require 'lash-sprites/sprite'
require 'lash-sprites/css'
require 'lash/assets_host'
require 'fileutils'

module Lash
  # Bundles a series of loose images into a single CSS sprite and generates a corresponding CSS support
  # files
  class SpriteBundler
    
    # Bundles the images in the given directory into a single large CSS sprite image
    #
    # @param [String] directory the directory of images to bundle into a sprite
    #
    # @option options [Boolean] :sass         Generate a SASS script for importing into a master.scss script
    # @option options [Boolean] :class_name   The css class name, defaults to name of directory
    # @option options [Boolean] :sprite_file  The name of the png sprite to generate. Defaults to `#{directory}-sprite.png`
    # @option options [Boolean] :css_file     The name of the CSS file to generate
    #
    # @example
    #
    #     bundler.bundle "ui"         # => public/images/ui-sprite.png
    #                                 # => public/sprites/sass/_ui-sprite.scss 
    def bundle( directory, options = nil )
      options = resolve_options( options || {}, directory )
      
      sprite = create_sprite_image( options )
      generate_css( sprite, options )      

      puts "=> bundled css at #{ Lash::Files.relative_to( options[:css_file], Rails.root )}" if options[:log]
    end
    
    private
      def resolve_options( options, directory )
        options[:directory]     =   File.expand_path( directory, File.join( Rails.root, "public/sprites" ) )
        options[:sass]          =   Lash.lash_options[:use_sass] unless options.has_key?(:sass) or !Gem.available?(:sass)
        options[:class_name]    ||= ( File.basename( directory ) ).parameterize
        options[:sprite_name]   ||= ( File.basename( directory ) + '-sprite' ).parameterize
        options[:sprite_file]   ||= File.join( Rails.root, "public/images", "#{options[:sprite_name]}.png")
        options[:css_file]      ||= options[:sass] \
          ? File.join( Rails.root, 'public/stylesheets/sass/', "_#{options[:sprite_name]}.scss" )
          : File.join( Rails.root, 'public/stylesheets/', "#{options[:sprite_name]}.css" )
        options
      end
      
      def create_sprite_image( options )
        sprite_files  = Lash::Files.recursive_file_list( options[:directory], /\.(jpe?g|png|gif)$/ )
        FileUtils.rm_rf( options[:sprite_file] )
        sprite = RubySprites::Sprite.new( Lash::Files.relative_to( options[:sprite_file], Rails.root ), 
                                          Rails.root, 
                                          :graphics_manager => :rmagick,
                                          :pack_type => 'both_smart' )

        sprite_files.each do |f|
          sprite.add_image( Lash::Files.relative_to( f, Rails.root ) )
        end

        sprite.update
        `#{File.expand_path ::File.join( __FILE__, '../../../bin/optipng')} -o7 \"#{sprite.filename}\"` if File.exists? sprite.filename
        
        
        sprite
      end
    
      def load_css_template( sprite_dir, template_name )
        css_template_file = File.join( sprite_dir, template_name );
        return IO.read(css_template_file) if File.exists? css_template_file
        nil
      end

      # Generates the acutal CSS sprite file
      def generate_css( sprite, options )
        width, height = best_width_and_height( sprite )
    
        asset_id = Lash::AssetsHost.asset_id( options[:sprite_file] )
        png_file = sprite.filename[6,sprite.filename.size-6]
        css = eval ( load_css_template( options[:directory], "template.css" ) ||
        '"
.#{options[:class_name]}-background { 
    background-image: url(..#{png_file}?#{asset_id}); 
    background-repeat: no-repeat;
}

.#{options[:class_name]} { 
  background-color: transparent;
  background-image: url(..#{png_file}?#{asset_id}); 
  background-repeat: no-repeat;
  overflow: hidden;
  text-indent: 99999px;
  *text-indent: 999px; // IE 7 fix
  text-align: left!important;
  width: #{width}px;
  height: #{height}px;
}

"' )
    
        css_sprite_template = load_css_template( options[:directory], "sprite-template.css" ) || '
          ".#{options[:class_name]}-#{name} { background-position: -#{image.x}px -#{image.y}px;#{ "width: #{image.width}px; " if image.width != width }#{ "height: #{image.height}px; " if image.height != height } }\n" 
        '
    
        sprite.images.each do |path, image|
          name = File.basename( path )
          name = name[ 0, name.rindex( '.' ) ].gsub( '/', '-' )
          css += eval css_sprite_template
        end
    
        FileUtils.mkdir_p File.dirname( options[:css_file] )
    
        fp = File.open( options[:css_file], 'w+' )
        fp.write( css )
        fp.close
      end
      
      # Calculate most common width and height so sprites can default to most common dimensions
      def best_width_and_height( sprite )
        width_freq, height_freq = {}, {}
    
        sprite.images.each do |path,image|
          next unless image.width and image.height
    
          width_freq[image.width] = ( width_freq[image.width] || 0 ) + 1
          height_freq[image.height] = ( height_freq[image.height] || 0 ) + 1
        end
    
        [ width_freq.max_by { |e| e[1] }[0], height_freq.max_by { |e| e[1] }[0] ]
      end
    
    
  end
end