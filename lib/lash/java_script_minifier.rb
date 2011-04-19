

module Lash
  # Utility class for minifying a set of javascript sources
  class JavaScriptMinifier 
    
    attr_accessor :options
    
    
    # Compresses array of files into a single target minified script.
    def minify( files, target )
      if minify_scripts( files, target )
        gzip_bundle target
      end
    end
    
    private
      def compiler_options
        @options.inject("") do |o,p|
          v = if p[1]
            "#{p[0]} #{p[1]}"
          else
            p[0]
          end
          o = o + " " if o.length > 0
          o + v
        end
      end
    
      def minify_scripts( files, target )
        tmp = "#{target}.tmp"
        bundle_scripts files, tmp
        File.delete target if File.exist? target
        File.rename tmp, target
      end
      
      def bundle_scripts( files, bundle_target )
        File.open( bundle_target, "w+" ) do |t|          
          files.each do |file|
            File.open( file, "rb" ) do |f|
              t.write ";\n"
              t.write f.read
            end
          end          
        end
      end
      
      def temporary_bundle_file_for_target( target )
        
      end
    
      def gzip_bundle( target )
        %x{gzip -c -9 "#{target}" > "#{target}.gz"}
        File.size "#{target}.gz"
      end
    
  end
end