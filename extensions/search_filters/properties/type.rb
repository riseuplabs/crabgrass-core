SearchFilter.new('/type/:type_name/') do

  query do |query, type_name|
    query.add_type_constraint(type_name)
  end

  #
  # ui
  #

  self.section = :properties
  self.path_order = 100
  self.singleton = true

  html do
    content_tag(:p) do
      select_tag :type_name, options_for_select_page_type, :size => 8, :style => 'width:100%'
    end
  end

  label do |opts|
    type_name = opts[:type_name]
    if type_name
      "#{:type.t}: #{I18n.t(type_name, :default => type_name)}"
    else
     :type.t + '...'
    end
  end

end

