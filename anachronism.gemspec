# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift(lib) unless $:.include?(lib)

require 'anachronism/version'

Gem::Specification.new do |s|
  s.name = 'anachronism'
  s.version = Anachronism::VERSION
  s.license = 'MIT'
  s.author = 'Jonathan Castello'
  s.email = 'jonathan@jonathan.com'
  
  s.summary = 'Parses Telnet data into a stream of events'
  s.description = 'An Anachronism parser maps Telnet-compliant data to a stream of event objects.'
  s.required_ruby_version = '~> 1.9.0'
  
  s.files = Dir['ext/anachronism/*'].reject {|f| f =~ /(?:\/Makefile|\.(?:s?o|rl))$/} \
          + Dir['lib/**/*']
  s.require_paths << 'ext'
  s.extensions << 'ext/anachronism/extconf.rb'
  
  s.add_development_dependency 'rspec', '~> 2.1.0'
  s.add_development_dependency 'bundler', '~> 1.0.7'
end
