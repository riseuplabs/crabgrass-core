#
# A dummy filter used to show all the pages.
#

SearchFilter.new('/all/') do
  self.label = :all_pages
  # self.path_segment = '/all/'
end
