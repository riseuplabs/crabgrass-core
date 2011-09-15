
SearchFilter.new('/created-by/:user_id/') do

  query do |query, id|
    query.add_attribute_constraint(:created_by_id, user_id(id))
  end

  #
  # ui
  #

  self.exclude = 'created-by-me'
  self.singleton = true
  self.section = :advanced
  self.exclude = :created

  label do |opts|
    if opts[:user_id]
      :created_by_user.t(:user => user_login(opts[:user_id]).capitalize)
    else
      :created_by_dotdotdot.t
    end
  end

  self.description = :created_by_user_description
  html do
    content_tag(:p) do
      content_tag(:strong, :person.tcap) + " " +
      autocomplete_users_field_tag('user_id')
    end
  end

end

