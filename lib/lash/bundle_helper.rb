require 'lash/lash_files'

module Lash
  module BundleHelper
    
    # Root folder where application javascript files can be found
    def javascript_root
       File.join( ::Rails.root, 'public', 'javascripts', '' )
    end

    # Determines if the processed bundle files should be used, or the loose files used to build those bundles.
    # By default bundled files are used in production or if the request includes a `:bundle` param or cookie.
    # @return [Boolean] true if bundled assets should be used.
    def bundle_files?
      if params.has_key? :bundle
        return /^t(rue)?|y(es)?|1$/i.match( params[:bundle] ) != nil
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
      # Generates javscript include tags for the actual bundled javascript for each named bundle
      def javascript_include_bundles( bundles )
        output = ""
        bundles.each do |bundle|
          output << javascript_src_tag( "bundle_#{bundle}.js", {} )
        end
        output.html_safe
      end

      # Generates javscript include tags for all the loose files for each named bundle
      def javascript_include_files( bundles )
        output = "\n"
        bundles.each do |bundle|
          files = Lash::Files.recursive_file_list( File.join( javascript_root, bundle ), '.js' )
          files.each do |file|
            file = file.gsub( javascript_root, '' )
            output << javascript_src_tag( file, {} ) + "\n" 
          end      
        end
        output.html_safe
      end


  end
end