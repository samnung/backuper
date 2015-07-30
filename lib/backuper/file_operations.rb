
module Backuper
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
  end
end