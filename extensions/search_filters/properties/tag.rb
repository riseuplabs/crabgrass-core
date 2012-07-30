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
  self.description = :filter_tag_description

  #
  # this gets invoked in the view with instance_eval, so it has the view's variables.
  #
  html(:delayed => true, :submit_button => false) do
    ret = content_tag(:p) do
      content_tag(:strong, :tag.tcap) + " " + text_field_tag('tag_name', nil, :onkeydown => "if (enterPressed(event)) {$('page_search_form').submit.click(); event.stop();}")
    end
    ret += "\n"

    # TODO---This means that we get the tags when loading the group or user page list. Instead, could we only figure out/load the tags if the user does a search by tag? It would be quicker, but maybe not enough to matter?
    tags_to_show = begin
      if @user == current_user
        current_user.tags
      elsif @group
        Page.tags_for_group(@group, current_user)
      else
        # Page.tags_for_user(@context, current_user)
      end
    end

    tags = tag_cloud(tags_to_show) do |tag, css_class|
      link_to_page_search tag.name, {:tag_name => tag.name}, :class => css_class
    end
    if tags
      ret += tags.join(' ')
    else
      ret += :no_things_found.t :things => :tags.t
    end
    ret
  end

  label do |opts|
    tag_name = opts[:tag_name]
    if tag_name.empty?
      :tag.t + '...'
    elsif tag_name.length > 15
      "#{:tag.t}: #{h tag_name[0..14]}..."
    else
      "#{:tag.t}: #{h tag_name}"
    end
  end

end

