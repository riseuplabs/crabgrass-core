module Pages::TagsHelper

  def remove_tag_link(tag)
    link = link_to_remote(
      I18n.t(:delete),
      { :url => page_tag_path(@page, tag.name),
        :method => :delete,
        :complete => hide("tag_#{tag.id}") },
      { :class => 'shy', :icon => 'tiny_trash'}
    )
    content_tag(:p, h(tag.name) + ' ' + link, :id => "tag_#{tag.id}", :class => 'shy_parent small_icon tag_16')
  end

  def options_for_edit_tag_form
    [{
      :url => page_tags_path(@page),
      :method => :post,
      :page_id => @page.id,
      :html     => {:id => 'edit_tag_form'},
      :loading  => show_spinner('tag')
#      :complete => hide_spinner('tag')
#      :success  => reset_form('edit_tag_form')
    }]
  end

end

