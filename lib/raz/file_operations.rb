
module Raz
  module FileOperations
    class NotExistingFile < ::StandardError; end
    class UnknownFileType < ::StandardError; end

    # Method to copy file and keep same informations (owner, mtime, ...) as original file
    #
    # @param src [String]
    # @param dest [String]
    #
    def copy_item(src, dest)
      if !File.exist?(src)
        raise NotExistingFile, "Unknown file type for source #{src}"
      elsif File.directory?(src)
        FileUtils.cp_r(src, dest, preserve: true)
      elsif File.file?(src)
        FileUtils.cp(src, dest, preserve: true)
      else
        raise UnknownFileType, "Unknown file type for source #{src}"
      end
    end

    module_function :copy_item

    # @param path [String] path to folder
    #
    # @return [Array<String>]
    #
    def dir_entries(path)
      entries = Dir.entries(path)
      entries.delete('.')
      entries.delete('..')
      entries
    end

    module_function :dir_entries
  end
end