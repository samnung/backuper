module Backuper
  module Items
    class Group

      # @return [String]
      #
      attr_reader :name

      # @return [Array<String>]
      #
      attr_reader :paths

      def initialize(name, &block)
        @name = name
        @paths = []

        instance_eval(&block) unless block.nil?
      end

      ## API

      # @param path [String] path to file
      #
      def path(path)
        @paths << path
      end
    end
  end
end