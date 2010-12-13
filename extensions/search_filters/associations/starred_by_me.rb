SearchFilter.new('/starred-by-me/') do

  mysql do |query|
    query.add_sql_condition(
      'user_participations.user_id = ? AND user_participations.star',
      query.current_user.id
    )
  end

  # TODO: we don't have a multi attribute for 'starred_by_ids'
  #sphinx do |query, id|
  #  query.add_attribute_constraint(:starred_by_ids, user_id(id))
  #end

  #
  # ui
  #
 
  self.singleton = true
  self.section = :my_pages
  self.label   = :starred_by_me

end

