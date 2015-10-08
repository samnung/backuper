# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'backuper/version'


Gem::Specification.new do |spec|
  spec.name          = 'backuper'
  spec.version       = Backuper::VERSION
  spec.authors       = ['Roman Kříž']
  spec.email         = ['samnung@gmail.com']

  spec.summary       = 'Tool to backup and restore files.'
  spec.homepage      = 'https://github.com/samnung/backuper'
  spec.license       = 'MIT'

  spec.files         = Dir['bin/**/*'] + Dir['lib/**/*.rb'] + %w(backuper.gemspec Gemfile LICENSE.txt README.md)
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'gli'
  spec.add_runtime_dependency 'colorize'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
end
