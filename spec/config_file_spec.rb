require_relative 'spec_helper'

describe Backuper::ConfigFile do
  it 'can load config file' do
    config_file = Backuper::ConfigFile.new('fixtures/config_one')
    expect(config_file.items.size).to eq 2

    app_config = config_file.items[0]
    expect(app_config).to be_an_instance_of(Backuper::Items::Application)
    expect(app_config.paths).to contain_exactly('~/Library/Application Support/SourceTree')
    expect(app_config.name).to eq 'SourceTree'

    group_config = config_file.items[1]
    expect(group_config).to be_an_instance_of(Backuper::Items::Group)
    expect(group_config.paths).to contain_exactly('~/.gitignore')
    expect(group_config.name).to eq 'Dot files'
  end
end