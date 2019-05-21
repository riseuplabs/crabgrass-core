module GalleryHelper

  def gallery_display_image_position
    if @image_index
      I18n.t(:image_count, number: @image_index.to_s, count: @image_count.to_s)
    else
      I18n.t(:image_count_total, count: @image_count.to_s)
                       end
  end

  def gallery_make_images_sortable_js
    sortable_element 'assets_list',
                     constraint: false,
                     overlap: :horizontal,
                     url: sort_images_url(page_id: @page)
  end

  def next_image_link
    if @next
      url = image_url(@next.asset_id, page_id: @page)
      link_to(:next.t, url,
        remote: true,
        method: :get,
        class: 'btn btn-default',
        icon: 'right')
    else
      "<span class='btn btn-default disabled icon right_16'>#{:next.t}</span>".html_safe
    end
  end

  def previous_image_link
    if @previous
      url = image_url(@previous.asset_id, page_id: @page)
      link_to(:previous.t, url,
        remote: true,
        method: :get,
        class: 'btn btn-default',
        icon: 'left')
    else
      "<span class='btn btn-default disabled icon left_16'>#{:previous.t}</span>".html_safe
    end
  end
end
