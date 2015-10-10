
require 'yaml'
require_relative 'file_operations'
require_relative 'constants'

include Raz::Constants


module Raz
  class Restorer

    # @return [String]
    #
    attr_reader :source_path

    # @param source_path [String]
    #
    def initialize(source_path)
      @source_path = source_path
    end

    def restore
      # load saved information from YAML
      @info = YAML.load(File.read(File.join(@source_path, BACKUP_INFO_BASE_PATH)))
      @orig_home_path = @info[:env]['HOME']

      # load config file
      config = ConfigFile.new(backup_config_file_path(@source_path))

      # run before procs
      (config.procs[:before_restore] || []).each do |proc|
        instance_eval(&proc)
      end

      # restore all files
      @info[:copied_paths].each do |src|
        dest = destination_path_from_original(src)
        src = File.join(@source_path, BACKUP_DATA_BASE_PATH, src)

        if File.directory?(dest)
          FileOperations.dir_entries(src).each do |item|
            puts "Restoring file to #{File.join(dest, item)}".green
            FileOperations.copy_item(File.join(src, item), dest)
          end
        else
          FileUtils.rmtree(dest) if File.exist?(dest)
          FileUtils.mkdir_p(File.dirname(dest))

          puts "Restoring item to #{dest}".green
          FileOperations.copy_item(src, dest)
        end
      end

      # restore config file to previous location
      orig_config_path = destination_path_from_original(@info[:orig_config_path])
      FileUtils.mkdir_p(File.dirname(orig_config_path))
      FileOperations.copy_item(config.path, orig_config_path)

      # run after procs
      (config.procs[:after_restore] || []).each do |proc|
        instance_eval(&proc)
      end
    end

    private

    # @param path [String]
    #
    # @return [String]
    #
    def destination_path_from_original(path)
      path.sub(/^#{Regexp.escape(@orig_home_path)}/, ENV['HOME'])
    end
  end
end
