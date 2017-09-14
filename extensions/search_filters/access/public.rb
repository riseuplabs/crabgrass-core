
SearchFilter.new('/public/') do
  query(&:add_public)

  #
  # ui
  #

  self.path_order = 10
  self.section = :access
  self.label = :public
  self.singleton = true
end
