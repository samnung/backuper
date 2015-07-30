
require 'yaml'
require 'colorize'
require_relative 'file_operations'


module Backuper
  class Backuper
    include FileOperations

    # @return [String]
    #
    # @warn Value is valid only during method backup, is meant for config files
    #
    attr_reader :destination_path

    # @param config [Backuper::ConfigFile]
    #
    def initialize(config)
      @config = config
    end

    # Main method to back all files from configuration
    #
    # @param destination_path [String] path to folder where should be files stored
    #
    def backup(destination_path)
      FileUtils.mkdir_p(destination_path)

      dest_contents = dir_entries(destination_path)

      raise "Can only operate on empty or non-existing directory! Directory #{destination_path} contains: #{dest_contents}" unless dest_contents.empty?

      @paths_to_copy = []
      @destination_path = destination_path

      # run before procs
      @config.procs[:before_backup].each do |proc|
        instance_eval &proc
      end

      # process all items from configuration file
      @config.items.each do |item|
        process_item(item)
      end

      # copy all processed files
      @paths_to_copy.each do |path|
        dest_path = destination_path_from(path)
        dest_dir = File.dirname(dest_path)
        FileUtils.mkdir_p(dest_dir)

        # TODO: copy owner and permissions

        copy_item(path, dest_path)
      end

      # save info for restorer
      save_info

      # backup config folder
      copy_item(File.dirname(@config.path), @destination_path)
      FileUtils.mv(File.join(@destination_path, '.backuper'), File.join(@destination_path, 'config_folder'))

      # run after procs
      @config.procs[:after_backup].each do |proc|
        instance_eval &proc
      end

      @paths_to_copy = nil
      @destination_path = nil
    end

    private

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
        ignored_paths = @config.ignored_paths + @current_item.ignored_paths

        ok = ignored_paths.all? do |ignore_path|
          !File.fnmatch(File.expand_path(ignore_path), path, File::FNM_PATHNAME)
        end

        if ok
          @paths_to_copy << path
        else
          # puts "ignoring path #{path}"
        end
      end
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

    def save_info
      info = {
          env: ENV.to_hash,
          copied_paths: @paths_to_copy,
          orig_config_path: @config.path,
      }

      File.write(File.join(@destination_path, 'backuper_info.yaml'), info.to_yaml)
    end
  end
end