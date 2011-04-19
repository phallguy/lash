require 'find'

module Lash
  module Files
  
    # Collects an array of all files in {basedir} with the given ext.
    #
    # @param [String] basedir the root directory to search
    # @param [String] ext extension to filter results by
    # @return [Array] an array of expanded paths for each file in {basedir} and any of it's sub directories
    def self.recursive_file_list( basedir, ext )
      unless ext.is_a? Regexp
        ext = ".#{ext}" if ext && ext[0] != ?.
        ext ||= ""
      end
      
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
        if ext.respond_to? :match
          files << path if ext.match( path )
        else
          files << path if File.extname( path ) == ext
        end
      end
      files.sort
    end
    
    # Gets all the top level directories in the given base_path
    #
    # @param [String] basedir the root directory to search
    # @return [Array] an array of expanded paths for all directories found
    def self.get_top_level_directories( basedir )
      Dir.entries( basedir ).collect do |path|
        path = File.join( basedir, path )
        File.basename( path )[0] == ?. || !File.directory?( path ) ? nil : path # not dot directories or files
      end - [nil]
    end
    
    # Gets the relative path from root to path of path is a subdirectory of root, otherwise returns path
    def self.relative_to( path, root )
      path = File.expand_path( path )
      root = File.expand_path( root )
      return path unless path.start_with? root
      path[ root.length + 1, path.length ]
    end
    
  end
end