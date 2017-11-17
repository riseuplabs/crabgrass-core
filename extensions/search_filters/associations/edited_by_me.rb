SearchFilter.new('/edited-by-me/') do
  mysql do |query, _id|
    query.add_sql_condition(
      'user_participations.user_id = ? AND user_participations.changed_at IS NOT NULL',
      query.current_user.id
    )
    query.add_order('user_participations.changed_at DESC')
  end

  # TODO: currently, updated_by_id is not a multi-attribute... it just hold
  # the most recent user id. This could be changed easily enough to be
  # a multi attribute that held the user ids of all the people who have modified
  # the page. then this query would work:
  sphinx do |query, _id|
    query.add_attribute_constraint(:updated_by_id, query.current_user.id)
  end

  #
  # ui
  #

  self.singleton = true
  self.section = :my_pages

  label do |opts|
    if opts[:remove]
      :edited_by_user.t(user: :me.t)
    else
      :edited.t
    end
  end
end
