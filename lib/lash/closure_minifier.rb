require 'lash/java_script_minifier'

module Lash
  class ClosureMinifier < JavaScriptMinifier
    
    private 
      def minify_scripts( files, target )
        tmp = "#{target}.tmp"
        `java -jar \"#{Lash.lash_options[:closure_compiler]}\" #{command_options} --warning_level QUIET --js \"#{files.join("\" --js \"")}\" --js_output_file \"#{tmp}\"`
        if $?.exitstatus == 0   
          File.delete target if File.exist? target
          File.rename tmp, target
        end        
      ensure
        File.delete tmp if File.exist? tmp
      end
    
  end
end