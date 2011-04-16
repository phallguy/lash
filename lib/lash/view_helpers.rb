module Lash
  module ViewHelpers
    # Options for bundle helpers are optional and get their default values
    # from the Lash::ViewHelpers.lash_options hash. You can write
    # to this hash to override default options on the global level:
    #
    #   Lash::ViewHelpers.lash_options[:unicorns] = 'run free'
    #
    def self.lash_options() @lash_options; end
    # Overrides the default {lash_options}
    def self.lash_options=(value) @lash_options = value; end
    
    self.lash_options = {
      #:container      => true
    }
  end
end
