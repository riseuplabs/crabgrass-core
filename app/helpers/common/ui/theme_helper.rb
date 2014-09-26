#
# Here are helpers specific to the particular themes that crabgrass uses.
#
# For helpers relating to the general theme plugin, see the plugin directory.
#

module Common::Ui::ThemeHelper

  ##
  ## COLUMN LAYOUT
  ##

  #
  # returns the width, in pixels, of the sidecolumn.
  #
  def sidecolumn_width
    @sidecolumn_width ||= begin
      current_theme.columns_width(current_theme.local_sidecolumn_width)
    end
  end

  #
  # returns the width, in pixels, of the inside of the sidecolumn,
  # assuming the application of local_content_padding.
  #
  def sidecolumn_inside_width
    @sidecolumn_inside_width ||= begin
      sidecolumn_width - 2 * current_theme.resolve_width(current_theme.local_content_padding)
    end
  end

  ##
  ## BANNER
  ##

  def banner_width
    @banner_width ||= begin
      current_theme.columns_width(current_theme.grid_column_count)
    end
  end

  def banner_height
    @banner_height ||= begin
      current_theme.int_var(:banner_padding) * 2 + current_theme.int_var(:icon_large) + 4
    end
  end

  def link_to_banner_title(entity, size=nil)
    if size
      link_to_entity(entity, class: 'title', format: :full, style: 'line-height: %spx' % Avatar.pixel_width(size))
    else
      link_to_entity(entity, class: 'title', format: :full)
    end
  end

end

