require 'fileutils'
require 'lash/files'
require 'lash/closure_minifier'

module Lash
  
  # Bundles JavaScripts into single files or individually minified scripts
  #
  # ## Example
  #
  #     bundler = JavaScriptBundler.new
  #     bundler.bundle( "application", :style => :single )      # => bundle_application.js
  #     bundler.bundle( "demand", :style => :individual )       # => demand/form.min.js
  #                                                             # => demand/fancybox.min.js
  #
  class JavaScriptBundler
   
    
    def initialize( options = nil )
      @options ||= {}
      @minifiers = [ options[:minifiers] || ClosureMinifier.new ].flatten
      @options[:javascripts_path] ||= File.expand_path( File.join( Rails.root, "public/javascripts" ) )
      @demand_dirs ||= options[:demand_dirs] || ["demand"]      
      @cdn_dirs ||= options[:cdn_dirs] || ["cdn"]      
    end
    
    # Bundles all the scripts in the {directory}
    def bundle( directory, options = nil )
      options = resolve_options( options || {}, directory )
      files = Lash::Files.recursive_file_list( options[:directory], '.js' )
      
      case options[:style]
      when :single
        bundle_into_single_script files, options
      when :individual
        files = files.reject{ |f| f.end_with? 'min.js' }
        bundle_individual_scripts files, options
      end
    end
    
    def bundle_style( directory )
      infer_style_from_directory directory
    end
    
    private
    
      def resolve_directory( directory )
        File.expand_path( directory, @options[:javascripts_path] )
      end
    
      def infer_style_from_directory( directory )
        individual = (( @cdn_dirs || [] ) + ( @demand_dirs || [] )).map{ |d| resolve_directory d }
        individual.include?( directory ) ? :individual : :single
      end
    
      def resolve_options( options, directory )
        options[:directory] = resolve_directory( directory )
        options[:style] ||= infer_style_from_directory( options[:directory] )
        options[:target_dir] ||= @options[:javascripts_path]
        options[:log] = @options[:log] unless options.has_key? :log
        options
      end
      
      def bundle_into_single_script( files, options )
        bundle_scripts_with_best_minifier( files, options )
      end
      
      def bundle_individual_scripts( files, options )
        files.each do |f|
          unless bundle_scripts_with_best_minifier( [f], options )
            return false
          end
        end
      end
      
      def bundle_scripts_with_best_minifier( files, options )
        targets = []
        @minifiers.each do |m|
          target = bundle_scripts_with_minifier( files, options, m )          
          targets << target if target
        end

        return nil unless targets.length > 0
        
        migrate_best_target( targets, options.merge({
          :target_bundle => bundle_target_name( files, options )
        }))        
        true
      ensure
        targets.each { |f| FileUtils.rm_f f }
      end
      
      def bundle_target_name( files, options )
        options[:style] == :single \
            ? File.join( options[:target_dir], "bundle_#{File.basename( options[:directory] ).parameterize}.js" )
            : File.join( options[:directory], "#{File.basename( files.first, '.js' )}.min.js" )
      end
      
      def migrate_best_target( targets, options )
        smallest = targets.min_by { |f| File.size( f ) }
        FileUtils.mv smallest, options[:target_bundle], :force => true
        FileUtils.mv smallest + '.gz', options[:target_bundle] + '.gz', :force => true if File.exist? smallest + ".gz"
        
        puts "Bundled to #{options[:target_bundle]}" if options[:log]
      end
      
      def bundle_scripts_with_minifier( files, options, minifier )
        target = bundle_target_name( files, options ) + ".#{minifier.class.name.parameterize}"
        if minifier.minify( files, target )
          target
        else
          nil
        end        
      end
    
  end
end