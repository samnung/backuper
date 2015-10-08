
ignore_path '**/.DS_Store'


app 'SourceTree' do
  path '~/Library/Application Support/SourceTree'
  ignore_path '~/Library/Application Support/SourceTree/ImageCache/**/*'
end

group 'Dot files' do
  path '~/.gitignore'
end


before_backup do
  system 'echo before_backup'
end

after_backup do
  system 'echo after_backup'
end

before_restore do
  system 'echo before_restore'
end

after_restore do
  system 'echo after_restore'
end
