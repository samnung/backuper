
require 'yaml'
require_relative 'file_operations'


module Backuper
  class Backuper
    include FileOperations

    # @param config [Backuper::ConfigFile]
    #
    def initialize(config)
      @config = config
    end

    def backup(destination_path)
      FileUtils.mkdir_p(destination_path)

      dest_contents = Dir.entries(destination_path)
      dest_contents.delete('.')
      dest_contents.delete('..')

      raise "Can only operate on empty or non-existing directory! Directory #{destination_path} contains: #{dest_contents}" unless dest_contents.empty?

      @config.items.each do |item|
        item.paths.each do |requirement_path|
          abs_requirement_path = File.expand_path(requirement_path)

          paths = if abs_requirement_path.include?('*')
                    Dir.glob(abs_requirement_path)
                  else
                    [abs_requirement_path]
                  end

          paths.each do |path|
            dest_path = File.join(destination_path, 'data', path)

            FileUtils.mkdir_p(File.dirname(dest_path))

            if !File.exist?(path)
              puts "Skipping file #{path}"
            elsif File.directory?(path)
              copy_directory(path, dest_path)
            elsif File.file?(path)
              copy_file(path, dest_path)
            else
              raise StandardError, "Unknown file type for path #{path}"
            end
          end
        end
      end

      info = {
          home: ENV['HOME'],
          user: ENV['USER']
      }

      File.write(File.join(destination_path, 'info.yaml'), info.to_yaml)
    end
  end
end