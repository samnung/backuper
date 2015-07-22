
require 'yaml'
require 'colorize'
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

      copied = []

      @config.items.each do |item|
        puts "Backing up #{item.name}"

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

            begin
              print "  Copying #{path} ... "
              copy_item(path, dest_path)
              puts 'Success'.green

              copied << path
            rescue NotExistingFile => e
              puts 'Skipping'.yellow
            end
          end
        end
      end

      info = {
          env: ENV.to_hash,
          copied_paths: copied,
      }

      File.write(File.join(destination_path, 'backuper_info.yaml'), info.to_yaml)
    end
  end
end