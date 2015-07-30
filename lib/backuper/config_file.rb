
require_relative 'items/group'
require_relative 'items/application'

module Backuper
  class ConfigFile

    # @return [String]
    #
    attr_reader :path

    # @return [Array<Backuper::Items::Group>]
    #
    attr_reader :items

    # @return [Array<String>]
    #
    attr_reader :ignored_paths

    # @return [Hash<Symbol, Array<Proc>>]
    #
    attr_reader :procs

    # @param path [String] path to configuration file
    #
    def initialize(path)
      @path = path
      @items = []
      @ignored_paths = []
      @procs = {}

      instance_eval(File.read(path), path)
    end

    # API

    def group(name, &block)
      @items << ::Backuper::Items::Group.new(name, &block)
    end

    def app(name, &block)
      @items << ::Backuper::Items::Application.new(name, &block)
    end

    def ignore_path(path)
      @ignored_paths << path
    end


    def before_backup(&block)
      @procs[:before_backup] ||= []
      @procs[:before_backup] << block
    end

    def after_backup(&block)
      @procs[:after_backup] ||= []
      @procs[:after_backup] << block
    end

    def before_restore(&block)
      @procs[:before_restore] ||= []
      @procs[:before_restore] << block
    end

    def after_restore(&block)
      @procs[:after_restore] ||= []
      @procs[:after_restore] << block
    end
  end
end