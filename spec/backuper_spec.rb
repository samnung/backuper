require_relative 'spec_helper'
require 'fileutils'

module Backuper
  describe Backuper do
    it 'has a version number' do
      expect(VERSION).not_to be nil
    end

    context 'Real files' do
      it 'copy file with same metas' do
        old = spec_path('testing_dir/prace_na_dalku.bookspec')
        new = spec_path('testing_dir/prace_na_dalku---copy.bookspec')

        FileOperations.copy_item(old, new)

        at_exit {
          FileUtils.rm(new)
        }

        expect(File::Stat.new(old)).to eq File::Stat.new(new)
      end

      it 'backup files' do
        dest = spec_path('testing_dir/backup_destination')
        FileUtils.rm_rf(dest)
        FileUtils.mkdir_p(dest)

        old_env     = ENV.to_hash
        ENV['USER'] = 'some_user'
        ENV['HOME'] = spec_path('fixtures/Users/some_user')

        backuper = Backuper.new(ConfigFile.new(spec_path('fixtures/Users/some_user/.backuper/config.rb')), dest)
        backuper.backup

        restorer = Restorer.new(dest)
        restorer.restore

        ENV.replace(old_env)
      end
    end

    context 'Fake files' do
      include FakeFS::SpecHelpers

      it 'parse desired files and directories' do
        FileUtils.mkdir_p_chdir('/1/2/3/4/5/6/7/8') do
          FileUtils.touch(%w(file.txt file2.txt))
        end

        FileUtils.mkdir_p('/dest')

        config = ConfigFile.new do |c|
          group 'Deep nested' do
            path '/1/2/3/4/5/6/7/8'
          end
        end

        backuper = Backuper.new(config, '/dest')
        backuper.investigate

        entries = backuper.parsed_entries
        expect(entries.count).to eq 1

        dir_entry = entries.first
        expect(dir_entry).to be_a DirEntry
        expect(dir_entry.name).to eq '8'
        expect(dir_entry.entries.count).to eq 2
        expect(dir_entry.entries.values.map(&:absolute_path)).to contain_exactly '/1/2/3/4/5/6/7/8/file.txt', '/1/2/3/4/5/6/7/8/file2.txt'
      end
    end

  end
end
