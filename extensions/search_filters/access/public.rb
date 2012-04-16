
SearchFilter.new('/public/') do

  query do |query|
    query.add_public
  end

  #
  # ui
  #

  self.path_order = 10
  self.section = :access
  self.label = :public
  self.singleton = true

end

