
#
# This is here instead of vendor/plugins/haml/init.rb, because I hate
# how haml keeps re-creating init.rb.
#

unless defined?(UNIT_TESTING)
  require 'haml'
  Haml.init_rails(binding)
end

