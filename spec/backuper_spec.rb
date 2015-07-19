require_relative 'spec_helper'
require 'fileutils'

include Backuper::FileOperations

describe Backuper do
  it 'has a version number' do
    expect(Backuper::VERSION).not_to be nil
  end

  it 'copy file with same metas' do
    old = 'prace_na_dalku.bookspec'
    new = 'prace_na_dalku---copy.bookspec'

    copy_file(old, new)

    at_exit {
      FileUtils.rm(new)
    }

    expect(File::Stat.new(old)).to eq File::Stat.new(new)
  end

  it 'backup files' do
    dest = 'backup_destination'
    FileUtils.rm_rf(dest)
    FileUtils.mkdir_p(dest)

    backuper = Backuper::Backuper.new(Backuper::ConfigFile.new('../fixtures/config_one'))
    backuper.backup(dest)
  end
end
