
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

    # @param source_path [String] path to file/folder
    #
    # @return [String]
    #
    def destination_path_from(source_path)
      File.join(@destination_path, 'data', source_path)
    end

    # Main method to
    #
    # @param destination_path [String] path to folder where should be files stored
    #
    def backup(destination_path)
      FileUtils.mkdir_p(destination_path)

      dest_contents = dir_entries(destination_path)

      raise "Can only operate on empty or non-existing directory! Directory #{destination_path} contains: #{dest_contents}" unless dest_contents.empty?

      @paths_to_copy = []
      @destination_path = destination_path

      @config.items.each do |item|
        process_item(item)
      end

      @paths_to_copy.each do |path|
        dest_path = destination_path_from(path)
        dest_dir = File.dirname(dest_path)
        FileUtils.mkdir_p(dest_dir)

        # TODO: copy owner and permissions

        copy_item(path, dest_path)
      end

      info = {
          env: ENV.to_hash,
          copied_paths: @paths_to_copy,
      }

      File.write(File.join(@destination_path, 'backuper_info.yaml'), info.to_yaml)

      @destination_path = nil
    end

    # @param item [Backuper::Items::Group] item to process
    #
    def process_item(item)
      @current_item = item

      puts "Processing group #{item.name}"

      item.paths.each do |requirement_path|
        print "  Processing path #{requirement_path} ... "

        abs_requirement_path = File.expand_path(requirement_path)

        paths = if %w(* ? { } [ ]).any? { |sym| abs_requirement_path.include?(sym) }
                  Dir.glob(abs_requirement_path)
                else
                  [abs_requirement_path]
                end

        paths.each do |path|
          # Skip not existing files/directories
          unless File.exist?(path)
            puts "Doesn't exist -> skipping".yellow
            next
          end

          process_path(path)
          puts 'Success'.green
        end
      end

      @current_item = nil
    end

    # @param path [String] path to process
    #
    def process_path(path)
      if File.directory?(path)
        dir_entries(path).each do |subitem|
          process_path(File.expand_path(subitem, path))
        end
      elsif File.file?(path)
        ok = @current_item.ignored_paths.all? do |ignore_path|
          !File.fnmatch(File.expand_path(ignore_path), path, File::FNM_PATHNAME)
        end

        if ok
          @paths_to_copy << path
        end
      end
    end
  end
end