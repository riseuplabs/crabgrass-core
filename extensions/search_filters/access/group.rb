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

  label do |opts|
    if opts[:group_id]
      "#{:group.t}: #{group_name(opts[:group_id])}"
    else
      :group.t + '...'
    end
  end

  self.description = :filter_group_description
  html do
    content_tag(:p, :id => :group_autocomplete) do
      content_tag(:strong, :group.tcap) + " " +
      autocomplete_groups_field_tag('group_id', :container => :group_autocomplete)
    end
  end

end

