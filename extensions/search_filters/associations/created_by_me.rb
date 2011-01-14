SearchFilter.new('/created-by-me/') do

  query do |query|
    query.add_attribute_constraint(:created_by_id, query.current_user.id)
  end

  #
  # ui
  #
 
  self.exclude = :created
  self.singleton = true
  self.section = :my_pages
  self.label   = :created_by_me

end

