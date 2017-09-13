SearchFilter.new('/owned-by-me/') do
  mysql do |query, _type, _id|
    query.add_sql_condition(
      'pages.owner_type = "User" AND pages.owner_id = ?',
      query.current_user.id
    )
  end

  sphinx do |query|
    id = Page.encode_user_id(query.current_user.id)
    query.add_attribute_constraint(:owner_id, id.to_i)
  end

  self.section = :my_pages
  self.exclude = :owned
  self.singleton = true
  self.label = :owned_by_me

  label do |opts|
    if opts[:add]
      :owned_by_me.t
    else
      :owned_by_user.t(user: :me.t)
    end
  end
end
