# -*- encoding: utf-8 -*-
require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rdoc/task'
require 'fileutils'

PROJECT_NAME    = "SourceScrubber"
GEM_NAME        = "source-scrubber"
LIB_PATH        = "lib"
BIN_PATH        = "bin"

require File.expand_path("#{LIB_PATH}/#{GEM_NAME}/version")

GEM_VERSION      = SourceScrubber::VERSION
RAKE_PATH        = File.dirname(__FILE__)
GEMSPEC_PATH     = File.join(RAKE_PATH, GEM_NAME+".gemspec")
RELEASE_PATH     = File.join(RAKE_PATH, "release")
GEMFILE          = "#{GEM_NAME}-#{GEM_VERSION}.gem"
RELEASE_GEM      = File.join(RELEASE_PATH, GEMFILE)
SOURCE_FILES     = Dir.glob("#{LIB_PATH}/**/*").select { |f| File.file?(f) }
BIN_FILES        = Dir.glob("#{BIN_PATH}/**/*").select { |f| File.file?(f) }
GEM_SOURCE_FILES = [SOURCE_FILES, BIN_FILES, GEMSPEC_PATH].flatten

CLEAN.include("#{GEM_NAME}-*.gem", RELEASE_PATH)

file RELEASE_GEM => GEM_SOURCE_FILES do
  gemfile = File.join(RAKE_PATH, GEMFILE)
  system "gem build #{GEMSPEC_PATH}"
  raise "Failed to build #{GEMFILE}" unless $?.success?
  raise "Failed to create #{GEMFILE} #{gemfile}" unless File.exists?(gemfile)
  FileUtils.mkdir(RELEASE_PATH) unless File.exists?(RELEASE_PATH)
  FileUtils.mv(gemfile, RELEASE_PATH)
end

desc "Build #{PROJECT_NAME} from gemspec"
task :build => [RELEASE_GEM] 

desc "Install #{PROJECT_NAME} v#{GEM_VERSION}"
task :install => [RELEASE_GEM] do
  gem_args = "--no-ri"
  raise "#{GEMFILE} has not been built" unless File.exists?(RELEASE_GEM)
  if ENV['http_proxy'].nil? or ENV['http_proxy'].empty?
    system "gem install #{RELEASE_GEM} -l #{gem_args}"
  else
    system "gem install #{RELEASE_GEM} -p \"#{ENV['http_proxy']}\" #{gem_args}"
  end
  raise "Failed to install #{RELEASE_GEM}" unless $?.success?
end

desc "Uninstall #{PROJECT_NAME}"
task :uninstall, :version do |t, args|
  args.with_defaults(:version => nil)
  gem_args = args[:version].nil? ? "-a -x -I" : "-x -I #{args[:version]}"
  system "gem uninstall #{gem_args} #{GEM_NAME}"
end

desc "update #{PROJECT_NAME} to latest version"
task :update do
  if Gem::Version(`gem list #{GEM_NAME}`.scan(/\d+\.\d+\.\d+/).max.to_s) < GEM_VERSION
    Rake::Task[:build].invoke
    Rake::Task[:uninstall].invoke
    Rake::Task[:install].invoke
  end
end

task :default => :build

