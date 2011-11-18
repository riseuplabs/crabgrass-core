module Wikis::AssetsHelper

  def image_size_buttons
    sizes = [:small, :medium, :large, :full]
    translated_sizes = sizes.map do |s|
      [s.t, s.to_s]
    end
    radio_buttons_tag 'image_size', translated_sizes,
      :id => 'image_size'
  end

  def image_full_size_link_checkbox
      check_box_tag('link_to_image', 'true', false) + :include_full_checkbox.t
  end

  def image_select_buttons
    return unless @images.any?
    render :partial => 'select_buttons'
  end

  def image_tags_and_ids(images)
    images.map do |image|
      [thumbnail_img_tag(image, :small, :scale => '64x64'), image.id]
    end
  end

  def data_tag_for_image(image)
    content_tag :input, '',
      :id => "#{image.id}_thumbnail_data",
      :value => thumbnail_urls_to_json(image),
      :type => 'hidden'
  end

  def thumbnail_urls_to_json(asset)
    { :small  => asset.thumbnail(:small).try.url || asset.url,
      :medium => asset.thumbnail(:medium).try.url || asset.url,
      :large  => asset.thumbnail(:large).try.url || asset.url,
      :full   => asset.url }.to_json
  end

  def insert_image_button
    button_to_function :insert_image.t,
      insert_image_function + close_modal_function
  end

  def insert_image_function
    "insertImage('%s');" % @wiki.id
  end

end
