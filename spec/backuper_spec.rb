require_relative 'spec_helper'
require 'fileutils'

include Backuper::FileOperations

describe Backuper do
  it 'has a version number' do
    expect(Backuper::VERSION).not_to be nil
  end

  it 'copy file with same metas' do
    old = spec_path('testing_dir/prace_na_dalku.bookspec')
    new = spec_path('testing_dir/prace_na_dalku---copy.bookspec')

    copy_item(old, new)

    at_exit {
      FileUtils.rm(new)
    }

    expect(File::Stat.new(old)).to eq File::Stat.new(new)
  end

  it 'backup files' do
    dest = spec_path('testing_dir/backup_destination')
    FileUtils.rm_rf(dest)
    FileUtils.mkdir_p(dest)

    old_env = ENV.to_hash
    ENV['USER'] = 'some_user'
    ENV['HOME'] = spec_path('fixtures/Users/some_user')

    backuper = Backuper::Backuper.new(Backuper::ConfigFile.new(spec_path('fixtures/Users/some_user/.backuper/config.rb')))
    backuper.backup(dest)

    restorer = Backuper::Restorer.new(dest)
    restorer.restore

    ENV.replace(old_env)
  end
end
