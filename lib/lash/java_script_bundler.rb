require 'fileutils'
require 'lash/files'
require 'lash/java_script_minifier'

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
      @minifiers = [ options[:minifiers] || JavaScriptMinifier.new ].flatten
      @options[:javascripts_path] ||= File.join( Rails.root, "public/javascripts" )
    end
    
    # Bundles all the scripts in the {directory}
    def bundle( directory, options )
      options ||= {}
      
      files = Lash::Failes.recursive_file_list( directory, '.js' )
      
      case options[:style]
      when :single
        bundle_into_single_script files, options
      when :individual
        bundle_individual_scripts files, options
      end
    end
    
    private
    
      def resolve_options( options )
        options[:target_dir] ||= @options[:javascripts_path]
        options[:target_bundle] ||= "bundle_#{File.basename( directory )}.js"
      end
      
      def bundle_into_single_script( files, options )
        targets = []
        smallest, size = nil, 0
        @minifiers.each do |minfier|
          minifier_target = targets << "#{options[:target_bundle]}.#{minifier.class.parameterize}"
          minifier.minify files, minifier_target
          minifier_size = File.size( minifier_target )
          unless smallest && size < minifier_size
            size = minifier_size
            smallest = minifier_target
          end
        end
        
        FileUtils.mv_f smallest, options[:target_bundle]
      ensure
        targets.each { |t| File.delete t if File.exist? t }
      end
      
      def bundle_individual_scripts( files, options )
      end
      
      def bundle_script_with_minifier( file, options, minifier )
      end
    
  end
end