#
# NOT CURRENTLY WORKING
#

SearchFilter.new('/modified-by/:user_id/') do

  mysql do |query, id|
    query.add_sql_condition(
      'user_participations.user_id = ? AND user_participations.changed_at IS NOT NULL',
      user_id(id)
    )
    query.add_order("user_participations.changed_at DESC")
  end

  # TODO: currently, updated_by_id is not a multi-attribute... it just hold
  # the most recent user id. This could be changed easily enough to be
  # a multi attribute that held the user ids of all the people who have modified
  # the page. then this query would work:
  sphinx do |query, id|
    query.add_attribute_constraint(:updated_by_id, user_id(id))
  end

end

