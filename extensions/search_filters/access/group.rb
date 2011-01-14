SearchFilter.new('/group/:group_id/') do

  query do |query, id|
    query.add_access_constraint(:group_ids => [group_id(id)])
  end

  #
  # ui
  #

  self.path_order = 10
  self.section = :access
  self.singleton = false

  label do |id|
    if id
      "#{:group.t}: #{group_name(id)}"
    else
      :group.t + '...'
    end
  end

  self.description = :filter_group_description
  html do
    content_tag(:p) do
      content_tag(:strong, :group.tcap) + " " +
      autocomplete_groups_field_tag('group_id')
    end
  end

end

