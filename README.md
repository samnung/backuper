# Raz

[![Build Status](https://travis-ci.org/samnung/backuper.svg)](https://travis-ci.org/samnung/backuper)

Raz is simple tool to backup all files to some external hard drive and restoring with only four commands.

```bash
sudo gem install raz
raz backup /Volumes/Fry/Backup-2015-07-22

# ... and on another machine
sudo gem install raz
raz restore /Volumes/Fry/Backup-2015-07-22
```

Raz is designed to work on OS X and theoretically should work on Linux too.


## Motivation

I hate [mackup](https://github.com/lra/mackup) because of creating links to Dropbox or any other place and I am not big fan of Python.

I hate [Time Machine](https://en.wikipedia.org/wiki/Time_Machine_(OS_X)) because of backing up all files instead of specific ones (so when you want to reinstall to resolve some problems it doesn't work).

So I've created simple tool but with possibility to be powerfull in near future.


## Configuration file

Core of this tool is text file containing all files and directories should be backed up. There is no magic YAML, JSON, Config files with strange structure. Files uses Ruby syntax to define applications, their preferences and other valuable files. File must be located in home folder, exactly `~/.raz/config.rb`. Here is simple example of this tool can do:

```ruby
group 'Dot files' do
    path '~/.zprofile'
    path '~/.zshrc'
    # ...
    path '~/.git*' # everything starting with '.git' in home folder
end

app 'Sublime Text 3' do
  path '~/Library/Application Support/Sublime Text 3/'
  # ...
end

app 'Xcode' do
    path '~/Library/Developer/Xcode/UserData/CodeSnippets/'
    path '~/Library/Developer/Xcode/UserData/FontAndColorThemes/'
    # ...
end
```

`group` and `app` is same for now. Both supports adding path to files or folders to be backed up. You can also use wildcard expressions same as [`Dir.glob`](http://ruby-doc.org/core-2.2.0/Dir.html#method-c-glob) supports.


## License

The tool is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
