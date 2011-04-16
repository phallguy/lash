require 'find'

##
# Supports including bundled assets generated with the rake bundle:* tasks defined in {lib/tasks/bundle.rake}.
# Based on ["Optimizing asset bundling and serving with Rails"](https://github.com/blog/551-optimizing-asset-bundling-and-serving-with-rails) at github.
#
# # Rake Tasks
#
# There are a few supporting rake tasks that handle the actual bundling. These tasks can be run locally on the
# dev machine or on the server as part of a Capistrano recipe.
#
# ## JavaScript Tasks
#
#     rake bundle:js_bundle         
#
# Running this command will bundle all loose javascript files in a bundle and merge them into a single
# minified version. 
#
#     rake bundle:js_min
#
# Running this command will minify all javascripts in the application.
#
#     rake bundle:gzip_js
#
# Running this command will gzip all javascripts in the application for use with the `gzip_static` option in nginx.
#
# ## CSS Tasks
#
#     rake bundle:sass RAILS_ENV=production
#
# Pre-generates all SASSy stylesheets using production environment settings.
#
#     rake bundle:sprites
#
# Bundles all loose image files in `public/sprites/{bundle_name}` into a single large image with supporting
# CSS sprite style sheet in `stylesheets/sass/_{bundle_name}.scss` that can be included in the master CSS.
#
#     rake bundle:gzip_css
#
# Running this command will gzip all stylesheets in the application for use with the `gzip_static` option in nginx.
module Lash
  module BundleHelper
  
    # Root folder where application javascript files can be found
    JAVASCRIPT_ROOT = File.join( ::Rails.root, 'public', 'javascripts', '' )
  
    # Determines if the processed bundle files should be used, or the loose files used to build those bundles.
    # By default bundled fies are used in production or if the request includes a `:bundle` param or cookie.
    def bundle_files?
      if params.has_key? :bundle
        return params[:bundle] =~ /^t(rue)?|y(es)?|1$/i
      end
      Rails.env.production? || cookies[:bundle] == "yes"
    end
  
    # Generates a javascript include tag for each of the listed bundles.
    #
    # @return [String]
    # @example
    #   bundle_files?                             # => true
    #   <%= javascript_bundle 'common' %>         # => <script src="/javascripts/bundle_common.min.js" type="text/javascript"></script>
    #   bundle_files?                             # => false
    #   <%= javascript_bundle 'common' %>         # => <script src="/javascripts/cmmmon/application.js" type="text/javascript"></script>
    #                                             # => <script src="/javascripts/common/superfish.js" type="text/javascript"></script>
    def javascript_bundle( *sources )
      sources = sources.to_a
      bundle_files? ? javascript_include_bundles( sources ) : javascript_include_files( sources )
    end
  
    # Generates a javascript include tag that tries to first load the javascript from a CDN
    # source and if not availble, falls back to a local version of the script. Also uses local
    # versions of the scripts in development to make it easier to work offline. 
    #
    # Based on [Stack Overflow question](http://stackoverflow.com/questions/1014203/best-way-to-use-googles-hosted-jquery-but-fall-back-to-my-hosted-library-on-goo).
    #
    # @return [String]
    # @example
    #   bundle_files?         # => true
    #
    #   <%= javascript_cdn 'jquery', '//ajax.googleapis.com/ajax/libs/jquery/1.5.1/jquery.min.js', 'jQuery' -%>
    #   
    #   # => <script src="//ajax.googleapis.com/ajax/libs/jquery/1.5.1/jquery.min.js" type="text/javascript"></script>
    #   # => <script type="text/javascript">
    #   # =>  if(typeof jQuery === "undefined" ) 
    #   # =>    document.write( unescape("<script src=\"/javascripts/cdn/jquery.min.js?1297459967\" type=\"text/javascript\"><\/script>") );
    #   # => </script> 
    #
    #   bundle_files?         # => false
    #
    #   <%= javascript_cdn 'jquery', '//ajax.googleapis.com/ajax/libs/jquery/1.5.1/jquery.min.js', 'jQuery' -%>
    #   
    #   # => <script src="/javascripts/cdn/jquery.js?1299809021" type="text/javascript"></script> 
  
    def javascript_cdn( lib, cdn, test = nil )
      # http://stackoverflow.com/questions/1014203/best-way-to-use-googles-hosted-jquery-but-fall-back-to-my-hosted-library-on-goo
		
  		output = ""
      unless bundle_files?
        output << javascript_src_tag( "cdn/#{lib}", {} ) + "\n"
      else
        output << %{<script src="#{cdn}" type="text/javascript"></script>\n}
        output << %{<script type="text/javascript">if(typeof #{test} === "undefined" ) document.write( unescape("#{ escape_javascript javascript_src_tag( 'cdn/' + lib + '.min', {} )}") );</script>\n}.html_safe unless test.nil?
      end
      output.html_safe
    end
  
    private
      # Collects an array of all files in `{basedir}` with the given `{ext}`.
      def recursive_file_list( basedir, ext )
        files = []
        return files unless File.exist? basedir
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

      # Generates javscript include tags for the actual bundled javascript for each named bundle
      def javascript_include_bundles( bundles )
        output = ""
        bundles.each do |bundle|
          output << javascript_src_tag( "bundle_#{bundle}", {} )
        end
        output.html_safe
      end
  
      # Generates javscript include tags for all the loose files for each named bundle
      def javascript_include_files( bundles )
        output = "\n"
        bundles.each do |bundle|
          files = recursive_file_list( File.join( JAVASCRIPT_ROOT, bundle ), '.js' )
          files.each do |file|
            file = file.gsub( JAVASCRIPT_ROOT, '' )
            output << javascript_src_tag( file, {} ) + "\n" 
          end      
        end
        output.html_safe
      end

  
  end # module BundleHelper
end # module Lash