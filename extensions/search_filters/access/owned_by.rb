SearchFilter.new('/owned-by/:type/:id/') do

  mysql do |query, type, id|
    if type == 'person'
      add_sql_condition(
        'pages.owner_type = "User" AND pages.owner_id = ?',
         user_id(id)
      )
    elsif type == 'group'
      add_sql_condition(
         'pages.owner_type = "Group" AND pages.owner_id = ?',
         group_id(id)
      )
    end
  end

  # TODO: add onwer_id attribute
  sphinx do |query, type, id|
    if type == 'person'
      id = encoded_user_id(id)
    elsif type == 'group'
      id = encoded_group_id(id)
    end
    query.add_attribute_constraint(:owner_id, id)
  end

end

