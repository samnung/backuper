
module Backuper
  class DirEntry
    # @return [Hash<String, FileEntry | DirEntry>]
    #
    attr_accessor :entries

    # @return [Hash<String, FileEntry | DirEntry>]
    #
    attr_accessor :ignored_entries

    # @return [String]
    #
    attr_reader :name

    # @return [String]
    #
    attr_reader :absolute_path

    # @param [String] name
    #
    def initialize(name, absolute_path)
      @name            = name
      @absolute_path   = absolute_path
      @entries         = {}
      @ignored_entries = {}
    end

    def [](key)
      @entries[key]
    end

    def []=(key, value)
      @entries[key] = value
    end

    def ==(other)
      name == other.name && entries == other.entries
    end

    def recursive_ignored_empty?
      return false unless ignored_entries.empty?

      dir_entries.all? do |entry|
        entry.recursive_ignored_empty?
      end
    end

    def dir_entries
      entries.select { |e| e.is_a?(DirEntry) }
    end

    def file_entries
      entries.select { |e| e.is_a?(FileEntry) }
    end

    def recursive_entries
      all_entries = []

      all_entries += entries
      all_entries += dir_entries.recursive_entries

      all_entries
    end
  end

  class FileEntry
    attr_reader :name

    attr_reader :absolute_path

    def initialize(name, absolute_path)
      @name          = name
      @absolute_path = absolute_path
    end

    def ==(other)
      absolute_path == if other.is_a?(FileEntry)
                         other.absolute_path
                       else
                         other.to_s
                       end
    end
  end
end