#
# load special libraries that won't get magically loaded otherwise.
#

unless UNIT_TESTING
  require "#{RAILS_ROOT}/app/stylesheets/sass_extension.rb"
end

require "#{RAILS_ROOT}/lib/crabgrass/exceptions.rb"

# model extensions:
require "#{RAILS_ROOT}/app/models/tag.rb"


