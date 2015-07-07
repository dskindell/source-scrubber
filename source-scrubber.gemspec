# -*- encoding: utf-8 -*-
require 'rubygems'
require 'rake'
require File.expand_path('lib/source-scrubber/version')

Gem::Specification.new do |s|
  s.name          = "source-scrubber"
  s.version       = SourceScrubber::VERSION
  s.platform      = Gem::Platform::RUBY
  s.license       = 'Copyright 2015 PMC-Sierra Inc., All Rights Reserved.'
  s.authors       = ["David Skindell"]
  s.email         = ["david.skindell@pmcs.com"]
  s.description   = %q{Find invalid non-utf8 chars, trailing whitespace and missing EOF in source files}
  s.summary       = %q{See "source-scrubber.rb --help" for usage}
  s.homepage      = ""

  s.required_ruby_version = '>= 1.9.3'

  s.add_dependency 'colorize', '~> 0'

  s.files         = Dir.glob('lib/**/*.rb')
  s.executables   = ["source-scrubber.rb"]
  s.require_paths = [ "lib" ]
end
