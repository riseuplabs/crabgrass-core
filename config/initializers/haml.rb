
#
# This is here instead of vendor/plugins/haml/init.rb, because I hate
# how haml keeps re-creating init.rb. 
#

require 'haml'
Haml.init_rails(binding)

