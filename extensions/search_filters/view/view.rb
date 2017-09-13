#
# not really a search filter, just determines how the page results are displayed
# also determines the default pagination size.
#

SearchFilter.new('/view/:mode/') do
  self.singleton = true
  self.path_order = 1000
end
