
require 'yaml'
require_relative 'file_operations'


module Backuper
  class Restorer
    include FileOperations

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
      @info = YAML.load(File.read(File.join(@source_path, 'backuper_info.yaml')))
      @orig_home_path = @info[:env]['HOME']

      # load config file
      config = ConfigFile.new(File.join(@source_path, 'config_folder', 'config.rb'))

      # run before procs
      config.procs[:before_restore].each do |proc|
        instance_eval &proc
      end

      # restore all files
      @info[:copied_paths].each do |src|
        dest = destination_path_from_original(src)
        src = File.join(@source_path, 'data', src)

        FileUtils.rmtree(dest) if File.exist?(dest)

        # TODO add some logs about restoring this file
        copy_item(src, dest)
      end

      # restore config file to previous location
      copy_item(config.path, destination_path_from_original(@info[:orig_config_path]))

      # run after procs
      config.procs[:after_restore].each do |proc|
        instance_eval &proc
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
