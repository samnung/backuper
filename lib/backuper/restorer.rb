
require 'yaml'
require_relative 'file_operations'


module Backuper
  class Restorer
    include FileOperations

    # @param backup_path [String]
    #
    def initialize(backup_path)
      @backup_path = backup_path
    end

    def restore
      info = YAML.load(File.read(File.join(@backup_path, 'backuper_info.yaml')))
      home_path = info[:env]['HOME']

      info[:copied_paths].each do |src|
        dest = src.sub(/^#{Regexp.escape(home_path)}/, ENV['HOME'])
        src = File.join(@backup_path, 'data', src)

        FileUtils.rmtree(dest) if File.exist?(dest)

        copy_item(src, dest)
      end
    end
  end
end
