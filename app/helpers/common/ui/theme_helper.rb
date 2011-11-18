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

  def link_to_banner_title(entity, size=nil)
    if size
      link_to_entity(entity, :class => 'title', :style => 'line-height: %spx' % Avatar.pixel_width(size))
    else
      link_to_entity(entity, :class => 'title')
    end
  end

  ##
  ## TYPOGRAPHY
  ##

  #
  #
  # return 'first' if this is the first time it has been called for +key+
  #
  # for example:
  #
  #   .p{:class => first(:list)}   --->   <p class="first"></p>
  #   .p{:class => first(:list)}   --->   <p></p>
  #   .p{:class => first(:list)}   --->   <p></p>
  #
  def first(key)
    @first_keys ||= {}
    if @first_keys[key]
      return nil
    else
      @first_keys[key] = true
      return 'first'
    end
  end

end

