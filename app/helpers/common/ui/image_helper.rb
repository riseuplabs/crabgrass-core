##
## Here in lies all the helpers for displaying icons, avatars
## and various images.
##

module Common::Ui::ImageHelper
  IMAGE_SIZES = Hash.new(200).merge(small: 64,
                                    medium: 200,
                                    large: 500).freeze

  ##
  ## ICON
  ##

  #
  # for example: icon_tag('pencil')
  #
  # currently, any 'size' argument other than the default will not display well.
  #
  def icon_tag(icon, size: 16, title: '')
    content_tag :i, ' ', class: "small_icon #{icon}_#{size}", title: title
  end

  ##
  ## PAGES
  ##
  ## every page has an icon.
  ##

  ## returns the img tag for the page's icon
  def page_icon(page)
    content_tag :i, ' ', class: "page_icon #{page.icon}_16"
  end

  ##
  ## PICTURES
  ##

  #
  # Displays a Picture object as the background image of an empty div.
  #
  # 'size' can be either a Symbol :small, :medium, :large, or a Hash
  # of the format used by Picture geometry (see picture.rb)
  #
  def picture_tag(picture, geometry)
    content_tag :div, '', style: picture_style(picture, geometry)
  end

  def picture_style(picture, geometry)
    geometry = picture.add_geometry(geometry)
    width, height = picture.size(geometry)
    format 'width: 100%%; max-width: %spx; height: %spx; background: url(%s)',
      width,
      height,
      picture.url(geometry)
  end

  ##
  ## ASSET THUMBNAILS
  ##

  #
  # creates an img tag for a thumbnail, optionally scaling the image or cropping
  # the image to meet new dimensions (using html/css, not actually scaling/cropping)
  #
  # eg: thumbnail_img_tag(asset, :medium, :crop => '22x22')
  #
  # thumbnail_name: one of :small, :medium, :large
  #
  # options:
  #  * :crop   -- the img is first scaled, then cropped to allow it to
  #               optimally fit in the cropped space.
  #  * :scale  -- the img is scaled, preserving proportions
  #  * :crop!  -- crop, even if there is no known height and width
  #
  # note: if called directly, thumbnail_img_tag does not actually do the
  #       cropping. rather, it generate a correct img tag for use with
  #       link_to_asset.
  #
  def thumbnail_img_tag(asset, thumbnail_name, options = {}, html_options = {})
    display = ThumbnailDisplay.new(asset, thumbnail_name, options)
    image_tag display.url, html_options.merge(display.thumbnail_img_options)
  end

  # links to an asset with a thumbnail preview
  def link_to_asset(asset, thumbnail_name, options = {})
    display = ThumbnailDisplay.new(asset, thumbnail_name, options)
    target_width = display.target_width || 32
    target_height = display.target_height || 32
    options[:class] ||= 'thumbnail'
    options[:title] ||= asset.filename
    options[:style]   = "height:#{target_height}px;width:#{target_width}px"
    url = options[:url] || asset.url
    img = image_tag display.url, display.thumbnail_img_options
    link_to img, url, options.slice(:class, :title, :style, :method, :remote)
  end

  class ThumbnailDisplay
    def initialize(asset, thumbnail_name, options = {})
      @asset = asset
      @thumbnail = asset.thumbnail(thumbnail_name)
      @options = options
      @options[:crop] ||= @options[:crop!]
    end

    #TODO: take crop! into account
    def thumbnail_img_options
      return { style: fallback_style } unless thumbnail
      if thumbnail.width && thumbnail.height
        style_options.merge size: size
      else
        {}
      end
    end

    def style_options
      if target_width > thumbnail.width || target_height > thumbnail.height
        { style: "margin: #{margin_y}px #{margin_x}px;" }
      else
        {}
      end
    end

    def size
      height = (thumbnail.height * ratio).round
      width  = (thumbnail.width * ratio).round
      return "#{width}x#{height}"
    end

    def fallback_style
      width, height = (options[:crop!] || '').split(/x/).map(&:to_f)
      if width.nil? or height.nil?
        'vertical-align: middle;'
      else
        "margin: #{(height - 22) / 2}px #{(width - 22) / 2}px;"
      end
    end

    def ratio
      # never scale up
      [1, fit_ratio].min
    end

    def url
      if thumbnail.present?
        thumbnail.url
      else
        "/images/png/16/#{asset.small_icon}.png"
      end
    end

    def target_width
      target_size.split(/x/).map(&:to_f).first ||
        (thumbnail && thumbnail.width)
    end

    def target_height
      target_size.split(/x/).map(&:to_f).second ||
        (thumbnail && thumbnail.height)
    end

    protected

    attr_reader :asset, :thumbnail, :options

    def fit_ratio
      if options[:crop]
        ratios.max
      else
        ratios.min
      end
    end

    def ratios
      [target_width / thumbnail.width, target_height / thumbnail.height]
    end

    def margin_x
      ((target_width - thumbnail.width) / 2) - border_width
    end

    def margin_y
      ((target_height - thumbnail.height) / 2) - border_width
    end

    def target_size
      (options[:crop] || options[:scale] || '')
    end

    def border_width
      1
    end
  end

  def icon_for(asset)
    image_tag "/images/png/16/#{asset.big_icon}.png",
      style: 'vertical-align: middle'
  end

end
