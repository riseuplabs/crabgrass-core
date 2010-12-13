#
# not really a search filter, just determines how the page results are displayed
#

SearchFilter.new('/view/:mode/') do

  #
  # ui
  #

  self.path_order = 1000
  self.section = :view

end

