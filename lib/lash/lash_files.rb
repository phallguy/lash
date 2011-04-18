require 'find'

module Lash
  module Files
  
    # Collects an array of all files in {basedir} with the given ext.
    #
    # @param [String] basedir the root directory to search
    # @param [String] ext extension to filter results by
    # @return [Array] an array of expanded paths for each file in {basedir} and any of it's sub directories
    def self.recursive_file_list( basedir, ext )
      ext = ".#{ext}" if ext && ext[0] != ?.
      ext ||= ""
      
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
    
  end
end