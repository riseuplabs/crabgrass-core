module Page::TagsHelper
  def remove_tag_link(tag)
    link = link_to_remote(
      :remove.t,
      { url: page_tag_path(@page, tag.name),
        method: :delete,
        complete: hide("tag_#{tag.id}") },
      class: 'shy inline', icon: 'tiny_trash'
    )
    content_tag(:div, id: "tag_#{tag.id}", class: 'shy_parent p') do
      content_tag(:span, h(tag.name), class: 'icon tag_16 inline') + ' ' +
        link
    end
  end

  def page_tag_delete_links
    haml do
      if @page.tags.any?
        haml '.two_column_float' do
          @page.tags.sort_by(&:name).each do |tag|
            haml '.column_item', remove_tag_link(tag)
          end
        end
      else
        haml '.p', :no_tags.t
      end
    end
  end

  def add_tag_link(tag)
    link = link_to_remote(
      :add_tags.t,
      {
        url: {action: :create, controller: 'tags', add: tag.name},
        },
      { class: 'shy inline', icon: 'plus'}
    )
    content_tag(:div, id: "tag_#{tag.id}", class: 'shy_parent p') do
      content_tag(:span, h(tag.name + " ("+ tag.taggings_count.to_s + ")"), class: 'icon tag_16 inline') + ' ' +
      link
    end
  end

  def page_tag_add_links
    if @page.owner_type == 'Group'
      tags = Page.tags_for_group(@page.owner, current_user)
    else
      tags = current_user.tags
    end
    tags = tags - @page.tags
    top_tags = tags.sort_by{|t| -t[:taggings_count]}.take(10)

    haml do
      if tags.any?
        haml '.two_column_float' do
          top_tags.each do |tag|
            haml '.column_item', add_tag_link(tag)
          end
        end
      else
        haml '.p', :no_tags.t
      end
    end
  end

end
