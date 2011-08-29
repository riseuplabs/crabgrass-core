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

  label do |opts|
    if opts[:remove]
      :created_by_user.t(:user => :me.t)
    else
      :created_by_me.t
    end
  end

end

