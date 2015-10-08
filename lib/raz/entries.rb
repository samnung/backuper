
module Raz
  class FileSystem
    # @return [DirEntry]
    #
    attr_reader :root_entry

    def initialize
      @root_entry = DirEntry.new('/', '/')
    end

    # @param [String | Array<String>] path  path to folder to create
    #
    # @return [DirEntry] dir entry for given path
    #
    def make_dir_p(path)
      components = path.split(File::SEPARATOR).reject(&:empty?)

      current = root_entry
      components.each do |dir|
        entry        = current[dir]
        current[dir] = entry = DirEntry.new(dir, path) if entry.nil?
        current      = entry
      end

      current
    end

    # @param [String] path
    #
    # @return [DirEntry]
    #
    def add_dir(path)
      make_dir_p(path)
    end

    # @param [String] path
    #
    # @return [FileEntry]
    #
    def add_file(path)
      entry = make_dir_p(File.dirname(path))

      file_entry = FileEntry.new(File.basename(path), path)
      entry[File.basename(path)] = file_entry
    end
  end

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

    # @return [Bool]
    #
    def recursive_ignored_empty?
      return false unless ignored_entries.empty?

      dir_entries.all? do |key, entry|
        entry.recursive_ignored_empty?
      end
    end

    # @return [Hash<String, FileEntry | DirEntry>]
    #
    def dir_entries
      entries.select { |_k, v| v.is_a?(DirEntry) }
    end

    # @return [Hash<String, FileEntry | DirEntry>]
    #
    def file_entries
      entries.select { |_k, v| v.is_a?(FileEntry) }
    end

    # @return [Array<FileEntry | DirEntry>]
    #
    def recursive_entries
      all_entries = []

      all_entries += entries.values
      all_entries += dir_entries.values.flat_map(&:recursive_entries)

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