require 'lash/view_helpers'

module Lash
  module ViewHelpers
    module Base
      
      # Root folder where application javascript files can be found
      def javascript_root
        File.join( ::Rails.root, 'public', 'javascripts', '' )
      end

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
      
    end
  end
end