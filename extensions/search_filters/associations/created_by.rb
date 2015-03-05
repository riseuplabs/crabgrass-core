
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
      :created_by_user.t(user: opts[:user_id].capitalize)
    else
      :created_by_dotdotdot.t
    end
  end

  self.description = :created_by_user_description
  html do
    content_tag(:p, id: :created_by_autocomplete) do
      content_tag(:strong, :person.tcap) + " " +
      autocomplete_input_tag('user_id', :users, container: :created_by_autocomplete)
    end
  end

end

