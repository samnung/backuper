require_relative 'spec_helper'
require 'fileutils'

describe Backuper do
  it 'has a version number' do
    expect(Backuper::VERSION).not_to be nil
  end

  it 'copy file with same metas' do
    old = 'prace_na_dalku.bookspec'
    new = 'prace_na_dalku---copy.bookspec'

    Backuper::FileOperations.copy_file(old, new)

    at_exit {
      FileUtils.rm(new)
    }

    expect(File::Stat.new(old)).to eq File::Stat.new(new)
  end
end
