#
# THEME COLUMN CALCULATIONS
#
# If the theme is set up to use percentage based columns,
# the methods here will expose percentage and pixel values
# for gutter and column widths.
#
# Basically, this is an implementation of Susy, but for use by ruby
# code instead of Sass.
#
# context_columns
#   the number of columns that form the context for the current
#   calculation. For example, suppose there are three columns to the
#   layout. Setting context_columns to '1' means that the calculation
#   should be made for html elements that are enclosed in an element
#   that is the width of 1 column (out of three). A value of nil
#   would be the same as '3', since the default is full width.
#
#

module Crabgrass::Theme::ColumnCalculator

  def setup_columns
    unless @total_columns
      @total_columns     = self['grid_column_count'].to_i
      @column_width      = pixels self['grid_column_width']
      @gutter_width      = pixels self['grid_column_gutter']
      @side_gutter_width = pixels self['grid_column_side_gutter']
    end
  end

  #
  # return the width in pixels of taken up by n 'context_columns'
  #
  # if 'context_columns' is not set, return the the full width
  # (including extra page padding)
  #
  def context_width(context_columns = nil)
    setup_columns
    side_gutter = 0
    unless context_columns
      context_columns =  @total_columns
      side_gutter = @side_gutter_width
    end
    context_columns = context_columns.to_f
    (context_columns * @column_width) +                 # with of n columns
    ((context_columns - 1).ceil * @gutter_width) +      # width of n - 1 gutters
    (side_gutter * 2)                                   # width of side gutters, if full width
  end

  #
  # return the percentage width of 'n' columns in a context of
  #  'context_columns'
  #
  def columns_width(n)
    setup_columns
    n = n.to_f
    (n * @column_width) + ((n - 1).ceil * @gutter_width)
  end

  #
  # columns_width, as percentage of the width of the context columns
  #
  def columns_width_percent(n, context_columns = nil)
    percent( columns_width(n) / context_width(context_columns) )
  end

  #
  # gutter width in pixels
  #
  def gutter_width
    @gutter_width
  end

  #
  # gutter width as percentage of context_columns
  #
  def gutter_width_percent(context_columns = nil)
    percent( gutter_width / context_width(context_columns) )
  end

  #
  # side gutter width in pixels
  #
  def side_gutter_width
    @side_gutter_width
  end

  #
  # side gutter width as percent of context_columns
  #
  def side_gutter_width_percent(context_columns = nil)
    percent( side_gutter_width / context_width(context_columns) )
  end

  #
  # return the width in pixels of a single column
  #
  def column_width
    @column_width
  end

  #
  # return the width in pixels of a single column, as percent of context
  #
  def column_width_percent(context_columns = nil)
    percent( column_width / context_width(context_columns) )
  end

  #
  # given a number of pixels, returns the width as parcent
  # of the current context_columns
  #
  def width_percent(pixels, context_columns = nil)
    percent( pixels.to_f / context_width(context_columns) )
  end

  #
  # Takes a width_string and returns the number of pixels.
  #
  # This allows widths to be expressed in units of 'g', for gutter.
  #
  # e.g. 1g = the width of the susy gutter.
  #
  def resolve_width(width_string, context_columns = false)
    str = width_string.to_s.gsub('"','')
    if str.match(/([0-9\.]+)g$/) # ends with 'g'?
      gutter_width * $1.to_f
    elsif str.match(/([0-9\.]+)px$/) # ends with 'px'?
      $1.to_f
    else
      0 # error, only support 'px' and 'g' as units.
    end
  end

  #
  # resolve_width as percentage of context_columns' width
  #
  def resolve_width_percent(width_string, context_columns = nil)
    percent( resolve_width(width_string) / context_width(context_columns) )
  end

  private

  # rounds a float, with three decimal precision
  def round(float)
    (float * 1000).round * 0.001
  end

  # converts ratio to a percentage with three decimal precision
  def percent(float)
    (float * 100000).round * 0.001
  end

  def pixels(str)
    if str.match(/([0-9\.]+)px$/)
      $1.to_f
    else
      raise '%s does not appear to be in pixel format' % str
    end
  end

end



