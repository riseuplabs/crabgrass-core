SearchFilter.new('/owned-by-me/') do

  mysql do |query, type, id|
    query.add_sql_condition(
      'pages.owner_type = "User" AND pages.owner_id = ?',
       query.current_user.id
    )
  end

  # TODO: add owner_id attribute
  sphinx do |query|
    id = encoded_user_id(query.current_user.id)
    query.add_attribute_constraint(:owner_id, id)
  end

  self.exclude = :owned
  self.singleton = true
  self.section = :my_pages
  self.label   = :owned_by_me

  label do |opts|
    if opts[:add]
      :owned_by_me.t
    else
      :owned_by_user.t(:user => :me.t)
    end
  end

end

