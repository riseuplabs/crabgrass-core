#
# load special libraries that won't get magically loaded otherwise.
#

unless defined? UNIT_TESTING
  require "#{Rails.root}/app/stylesheets/lib/sass_extension.rb"
end

require "#{Rails.root}/lib/crabgrass/exceptions.rb"

# model extensions:
require "#{Rails.root}/lib/extends/acts_as_taggable_on.rb"
