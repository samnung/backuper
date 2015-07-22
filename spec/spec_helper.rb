$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'backuper'

def spec_path(path)
  File.expand_path(path, File.dirname(__FILE__))
end