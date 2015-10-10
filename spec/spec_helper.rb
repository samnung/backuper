require 'fakefs/spec_helpers'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'raz'


def spec_path(path)
  File.expand_path(path, File.dirname(__FILE__))
end

module FakeFS
  module FileUtils
    def mkdir_p_chdir(paths)
      paths = Array(paths)

      paths.each do |path|
        mkdir_p(path)

        Dir.chdir(path) do
          yield path
        end
      end
    end
  end
end
