SearchFilter.new('/owned-by-me/') do

  mysql do |query, type, id|
    query.add_sql_condition(
      'pages.owner_type = "User" AND pages.owner_id = ?',
       query.current_user.id
    )
  end

  # TODO: add owner_id attribute
  sphinx do |query|
    id = Page.encode_user_id(query.current_user.id)
    query.add_attribute_constraint(:owner_id, id)
  end

  # This filter does not work with sphinx yet.
  # encoded_user_id is not implemented yet. So we disable it for now.
  #
  # There's a pending test for this in
  #   test/functionals/me/pages_controller_test.rb
  #
  self.section = :my_pages
  self.exclude = :owned
  self.singleton = true
  self.label   = :owned_by_me

  label do |opts|
    if opts[:add]
      :owned_by_me.t
    else
      :owned_by_user.t(:user => :me.t)
    end
  end

end

