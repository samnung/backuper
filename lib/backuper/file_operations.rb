
module Backuper
  module FileOperations
    # Method to copy file and keep same informations (owner, mtime, ...) as original file
    #
    # @param old_path [String|Array<String>]
    # @param new_path [String]
    #
    def self.copy_file(old_path, new_path)
      FileUtils.cp(old_path, new_path, preserve: true)
    end
  end
end