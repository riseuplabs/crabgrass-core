
SearchFilter.new('/owned-by/:type/:id/') do

  mysql do |query, type, id|
    if type == 'person'
      query.add_sql_condition(
        'pages.owner_type = "User" AND pages.owner_id = ?',
         user_id(id)
      )
    elsif type == 'group'
      query.add_sql_condition(
         'pages.owner_type = "Group" AND pages.owner_id = ?',
         group_id(id)
      )
    end
  end

  sphinx do |query, type, id|
    if type == 'person'
      id = Page.encode_user_id(user_id(id))
    elsif type == 'group'
      id = Page.encode_group_id(group_id(id))
    end
    query.add_attribute_constraint(:owner_id, id)
  end

end

