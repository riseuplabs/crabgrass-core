SearchFilter.new('/user/:user_id/') do

  query do |query, id|
    query.add_access_constraint(:user_ids => [user_id(id)])
  end

  #
  # ui
  #

  self.path_order = 10
  self.section = :access
  self.singleton = false

  label do |opts|
    if opts[:user_id]
      "#{:user.t}: #{user_login(opts[:user_id])}"
    else
      :user.t + '...'
    end
  end

  self.description = :filter_user_description
  html do
    content_tag(:p) do
      content_tag(:strong, :user.tcap) + " " +
      autocomplete_users_field_tag('user_id')
    end
  end

end

