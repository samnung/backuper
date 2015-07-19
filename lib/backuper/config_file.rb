
require_relative 'items/group'
require_relative 'items/application'

module Backuper
  class ConfigFile
    # @return [Array<Backuper::Items::Application>]
    #
    attr_reader :items

    # @param path [String] path to configuration file
    #
    def initialize(path)
      @path = path
      @items = []

      instance_eval(File.read(path), path)
    end

    # API

    def group(name, &block)
      @items << ::Backuper::Items::Group.new(name, &block)
    end

    def app(name, &block)
      @items << ::Backuper::Items::Application.new(name, &block)
    end
  end
end