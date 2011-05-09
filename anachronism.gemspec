# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift(lib) unless $:.include?(lib)

require 'anachronism/version'

Gem::Specification.new do |s|
  s.name = 'anachronism'
  s.version = Anachronism::VERSION
  s.license = 'MIT'
  s.author = 'Jonathan Castello'
  s.homepage = 'https://github.com/Twisol/anachronism'
  s.email = 'jonathan@jonathan.com'
  
  s.summary = 'A binding to libanachronism, a Telnet processing library.'
  s.description = 'Anachronism provides a simple Ruby interface to the Telnet protocol.'
  s.required_ruby_version = '~> 1.9.0'
  
  s.files = Dir['lib/**/*']
  
  s.add_dependency 'ffi', '~> 1.0.7'
  s.add_development_dependency 'bundler', '~> 1.0.7'
end
