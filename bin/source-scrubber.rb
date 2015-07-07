#!/usr/bin/env ruby
require 'optparse'
begin
  gem 'colorize'
  require 'colorize'
rescue LoadError
  STDERR.puts "WARNING: Failed to load gem colorize"
  class String
    unless instance_methods.include?(:red)
      def red
        self
      end
    end
  end
end

class String
  unless instance_methods.include?(:make_utf8)
    def make_utf8 options={}
      options = {
        invalid: :replace, 
        undef: :replace, 
        replace: ''
      }.merge(options)
      self.force_encoding('binary').encode('UTF-8', options)
    end
  end

  unless instance_methods.include?(:make_utf8!)
    def make_utf8! options={}
      self.replace(self.make_utf8(options))
    end
  end
end

DEFAULT_EXT_TO_IGNORE = %w(o obj bin exe a lib png jpg gif jif mpeg docx json).collect { |e| '.'+e }

begin
require 'source-scrubber/version'
rescue LoadError
require 'rubygems'
module SourceScrubber
  VERSION = GEM::Version.new('0.0.3.pre')
end
end

begin
  options = {
    exclude_extensions: DEFAULT_EXT_TO_IGNORE,
  }
  OptionParser.new do |opts|
    opts.banner = "Usage: source-scrubber.rb [OPTIONS]"
    opts.on('-f', '--file [FILE]', 'Scrub ONLY the given file.',
                                     ' Can be repeated for multiple files',
                                     ' (overrides -e & -d)') do |path|
      raise "Could not find FILE <#{path}>" unless File.file?(path)
      options[:files] ||= []
      options[:files] << (RUBY_PLATFORM =~ /linux/ ? path.strip : path.gsub('\\', '/').strip)
    end
    opts.on('-e', '--extension [EXT]', 'Only report files with extension EXT (i.e. cpp).',
                                         'Can provide multiple times') do |ext|
      raise "Invalid extension <#{ext}>" if ext.to_s.strip.empty?
      options[:extensions] ||= []
      options[:extensions] << ((ext.strip[0] == '.' ? '' : '.')+ext.strip)
    end
    opts.on('-x', '--exclude [EXT]', 'Exclude files with given extension EXT.',
                                     '  Can provide multiple times.',
                                     '  By default the following extensions are ignored:',
                                     "  #{DEFAULT_EXT_TO_IGNORE.join(' ')} <no extension>") do |ext|
      raise "Invalid extension <#{ext}>" if ext.to_s.strip.empty?
      options[:exclude_extensions] ||= []
      options[:exclude_extensions] << ((ext.strip[0] == '.' ? '' : '.')+ext.strip)
    end
    opts.on('-d', '--directory [PATH]', 'Search recursively from directory PATH.',
                                        '  (searchs from current directory otherwise)') do |path|
      raise "Could not find PATH <#{path}>" unless File.exists?(path)
      options[:directories] ||= []
      options[:directories] << (RUBY_PLATFORM =~ /linux/ ? path.strip : path.gsub('\\', '/').strip)
    end
    opts.on('--replace [STRING]', 'DANGEROUS! After reporting invalid characers',
                                  '  replace them in the file with STRING') do |rel|
      options[:replace] = rel
    end
    opts.on('--[no-]clean-whitespaces', 'If enabled: removes trailing whitespaces, ',
                                        '  if disabled: suppresses reporting trailing whitespaces') do |flag|
      options[:strip_lines] = flag
    end
    opts.on('--[no-]add-missing-newline', 'If enabled: adds missing newline to EOF, ',
                                          '  if disabled: suppresses reporting missing EOF newlines') do |flag|
      options[:add_last_newline] = flag
    end
    opts.on_tail('-h', '--help', 'Print this dialog') do
      puts opts
      exit
    end
    opts.on_tail('-v', '--version', 'Show version') do
      puts SourceScrubber::VERSION
      exit
    end
  end.parse!
  all_files = (options[:directories] || [Dir.pwd]).collect { |d|
    Dir[File.join(d, '**', '*')].select { |f| File.file?(f) }
  }.flatten
  unless options[:extensions].nil? or options[:extensions].empty?
    all_files.select! { |f| options[:extensions].any? { |ext| File.extname(f).upcase == ext.upcase } }
  end
  unless options[:exclude_extensions].nil? or options[:exclude_extensions].empty?
    all_files.reject! { |f| options[:exclude_extensions].any? { |ext| File.extname(f).upcase == ext.upcase } }
  end
  files = options[:files] || all_files
  files.each do |file|
    contents = File.open(file, 'r').read
    line_num = 1
    messages = []
    contents.each_line do |line|
      if line != line.make_utf8
        messages << "non-utf8 char at line:#{line_num}: #{line.make_utf8(replace: '?'.red).rstrip}"
      end
      if options[:strip_lines] != false and line =~ /[ \t]+\r?$/
        messages << "trailing whitespace at line:#{line_num}: #{line.make_utf8(replace: '?'.red).rstrip}"
      end
      line_num += 1
    end
    unless messages.empty?
    end

    rewrite_file = false
    old_contents = contents.clone

    unless options[:replace].nil?
      contents.make_utf8!(replace: options[:replace].to_s)
      rewrite_file = true
    end

    if options[:strip_lines] == true
      contents.gsub!(/[ \t]+(\r?)$/,'\1')
      rewrite_file = true
    end
    
    if contents[-1] != "\n"
      if options[:add_last_newline] != false
        messages << "missing newline at EOF"
      end
      if options[:add_last_newline] == true
        contents += "\n"
        rewrite_file = true
      end
    end

    unless messages.empty?
      puts "Issues in file: #{file}",
           messages.collect { |m| "  -> #{m}" }.join("\n")
    end
    if rewrite_file and contents != old_contents 
      File.open(file, 'w').write(contents)
    end
  end
rescue => e
  STDERR.puts e.to_s
  exit 1
end
