
#
# This is here instead of vendor/plugins/haml/init.rb, because I hate
# how haml keeps re-creating init.rb.
#

unless defined?(UNIT_TESTING)
  require 'haml'
  Haml.init_rails(binding)
end

# enable cache_digests for haml templates...
# https://github.com/rails/cache_digests/pull/46
# UPGRADE - this can go away once we use rails4 with haml_rails v5
CacheDigests::DependencyTracker.register_tracker :haml, CacheDigests::DependencyTracker::ERBTracker

