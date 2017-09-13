#
# pagination
#

SearchFilter.new('/page/:page_number/') do
  self.singleton = true
  self.path_order = 2000

  query do |query, page_number|
    query.add_pagination(page_number)
  end
end
