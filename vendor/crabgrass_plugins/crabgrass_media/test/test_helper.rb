
require 'test/unit'

pluginroot = File.dirname(File.dirname(__FILE__))
$: << pluginroot + '/lib'
require_relative '../init.rb'

def test_file(name)
  File.dirname(__FILE__) + '/files/' + name
end

def file_info_matches?(file, regex)
  `file #{file.to_s}` =~ regex
end

def file_info(file)
  `file #{file.to_s}`
end

def debug_progress(msg)
  puts "\t\tPROGRESS: %s" % msg
end
