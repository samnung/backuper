module Raz
  module Items
    class Group

      # @return [String]
      #
      attr_reader :name

      # @return [Array<String>]
      #
      attr_reader :paths

      # @return [Array<String>]
      #
      attr_reader :ignored_paths

      # @param name [String] name of this group
      # @param block [Proc] block where is specified all paths
      #
      def initialize(name, &block)
        @name = name
        @paths = []
        @ignored_paths = []

        instance_eval(&block) unless block.nil?
      end

      ## API

      # @param path [String] path to file
      #
      def path(path)
        @paths << path
      end

      # @param path [String] path to file
      #
      def ignore_path(path)
        @ignored_paths << path
      end
    end
  end
end
