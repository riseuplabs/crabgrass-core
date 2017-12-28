module Page::TagsHelper

  def remove_tag_link(tag)
    link = link_to :remove.t, page_tag_path(@page, tag.name),
      remote: true,
      method: :delete,
      icon: 'tiny_trash',
      data: {remove: "tag_#{tag.id}"},
      class: 'shy inline'

    content_tag(:div, id: "tag_#{tag.id}", class: 'shy_parent p') do
      content_tag(:span, h(tag.name), class: 'icon tag_16 inline') + ' ' + link
    end
  end

  def insert_remove_tag_link(tag)
    link = '<div class="column_item">' + remove_tag_link(tag) + '</div>'
  end

  def page_tag_delete_links
    haml do
      if @page.tags.any?
        haml '.two_column_float' do
          @page.tags.sort_by(&:name).each do |tag|
            haml '.column_item', remove_tag_link(tag)
          end
          haml '#added', ''
        end
      else
        haml '.two_column_float' do
          haml '#added', ''
        end
      end
    end
  end

  def add_tag_link(tag)
    link = link_to_remote(
      :add_tags.t,
      {
        url: {action: :create, controller: 'tags'},
        success: hide("tag_#{tag.id}"),
        complete: "$('added').insert({before: '#{insert_remove_tag_link(tag)}'})",
        with: "'add=#{tag.name}'",
        remote: true },
      { class: 'shy inline', icon: 'plus'}
    )
    content_tag(:div, id: "tag_#{tag.id}", class: 'shy_parent p') do
      content_tag(:span, h(tag.name), class: 'icon tag_16 inline') + ' ' +
      link
    end
  end


  def page_tag_add_links tags
    haml do
      if tags.any?
        haml '.two_column_float' do
          tags.each do |tag|
            haml '.column_item', add_tag_link(tag)
          end
        end
      else
        haml '.p', :no_tags.t
      end
    end
  end

end
