module Pages::TagsHelper

  def remove_tag_link(tag)
    link = link_to_remote(
      :remove.t,
      { url: page_tag_path(@page, tag.name),
        method: :delete,
        complete: hide("tag_#{tag.id}") },
      { class: 'shy inline', icon: 'tiny_trash'}
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
          @page.tags.sort_by{|t|t.name}.each do |tag|
            haml '.column_item', remove_tag_link(tag)
          end
        end
      else
        haml '.p', :no_tags.t
      end
    end
  end

end

