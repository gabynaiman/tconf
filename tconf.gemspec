# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tconf/version'

Gem::Specification.new do |spec|
  spec.name          = 'tconf'
  spec.version       = Tconf::VERSION
  spec.authors       = ['Gabriel Naiman']
  spec.email         = ['gabynaiman@gmail.com']
  spec.summary       = 'Esay way to update translations'
  spec.description   = 'Esay way to update translations'
  spec.homepage      = 'https://github.com/gabynaiman/tconf'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($\)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'class_config', '~> 0.0'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'pry'
end
