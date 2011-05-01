#
# defines a simple method 'info()' for printing debugging messages
#
# sometimes, it is much more useful to use print for debugging than
# to step through with a debugger.
#
# to enable the printing of the 'info()' messages, define the INFO
# environment variable:
#
#  INFO=1 ruby test/unit/user_test.rb
#
#  INFO=0 rake test:units
#
#  INFO=3 script/server
#
# The info level determines how much is shown:
#
# 0 -- only high level stuff
# 1 -- more detail
# 2 -- even more detail
# and so on...
#

unless defined?(DEFAULT_INFO_LEVEL)
  DEFAULT_INFO_LEVEL = -1
end

unless defined?(INFO_PAD_CHARACTER)
  INFO_PAD_CHARACTER = '-'
end

def info(str,level=0)
  if (ENV['INFO'] and ENV['INFO'].to_i >= level) or (DEFAULT_INFO_LEVEL >= level)
    str = str.to_s
    if INFO_PAD_CHARACTER.any?
      prefix = (INFO_PAD_CHARACTER * 2 * (level+1)) + ' ' + str + ' '
      postfix = INFO_PAD_CHARACTER * ([80 - prefix.length, 0].max)
      print prefix 
      puts postfix
    else
      puts(('  '*level) + str)
    end
    STDOUT.flush
  end
end

