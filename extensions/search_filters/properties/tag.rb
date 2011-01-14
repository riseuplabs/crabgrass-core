SearchFilter.new('/tag/:tag_name/') do

  query do |query, tag_name|
    query.add_tag_constraint(tag_name)
  end

  #
  # ui
  #
 
  self.path_order = 100
  self.section = :properties
  self.singleton = false

  html(:delayed => true, :submit_button => false) do 
    tag_cloud(current_user.tags) do |tag, css_class|
      link_to_page_search tag.name, {:tag_name => tag.name}, :class => css_class
    end.join(' ')
  end

  label do |tag_name|
    if tag_name.empty?
      :tag.t + '...'
    elsif tag_name.length > 15
      "#{:tag.t}: #{tag_name[0..14]}..."
    else
      "#{:tag.t}: #{tag_name}"
    end
  end

end

