#
# GEOMETRY
#
# A "geometry", for the purposes of Pictures, is an object with the
# following attributes:
#
#  min_width,  max_width
#  min_height, max_height
#
# All the attributes are optional. Attributes with a zero value
# become nil. Any method that accepts geometry argument will also
# take nil, which represents the unresized original image.
#
# Geometry.new will take three input forms:
#
# (1) Hash, like {:min_width => 50}
# (2) Array, like [50,0,0,0]
# (3) String, like "50-0-0-0"
#
#
# Picture::Geometry class
#
# We ensure that the attributes consists only of integers or nil.
# This is important, because we might have got the geometry source
# from a url.
#
class Picture::Geometry
  attr_accessor :min_width, :max_width, :min_height, :max_height

  def initialize(source = nil)
    set_limits *limits_from_source(source)
  end

  def self.[](geo)
    if geo.class == self
      geo
    else
      new(geo)
    end
  end

  def limits_from_source(source = nil)
    case source
    when Hash
      [source[:min_width], source[:max_width], source[:min_height], source[:max_height]]
    when Array
      source
    when String
      source.split('-')
    else
      []
    end
  end

  def set_limits(minw = nil, maxw = nil, minh = nil, maxh = nil)
    self.min_width  = minw.to_i if minw
    self.min_width  = nil       if min_width == 0
    self.max_width  = maxw.to_i if maxw
    self.max_width  = nil       if max_width == 0
    self.min_height = minh.to_i if minh
    self.min_height = nil       if min_height == 0
    self.max_height = maxh.to_i if maxh
    self.max_height = nil       if max_height == 0
  end

  def empty?
    !any?
  end

  def any?
    min_width || max_width || min_height || max_height
  end

  def to_s
    empty? ? 'full' : to_a.join('-')
  end

  def to_a
    empty? ? [] : [min_width || 0, max_width || 0, min_height || 0, max_height || 0]
  end

  #
  # Convert geometry definition into graphic magick compatible
  # resize options. The logic is complicated, but it tries
  # to do the right thing.
  #
  # summary from gm man page on -geometry:
  #
  #   1. WxH  -- max dimensions, resize with aspect ratio intact
  #   2. WxH^ -- min dimensions, resize with aspect ratio intact
  #   3. WxH! -- force dimensions exactly
  #   4. Wx   -- resize, maintain ratio, auto set height
  #   5. xH   -- resize, maintain ratio, auto set width
  #   6. WxH> -- shrink if bigger (W or H)
  #   7. WxH< -- expand if smaller (W and H)
  #
  def gm_size_param_from(orig_size)
    width = orig_size[0]
    height = orig_size[1]

    new_width = scale_to_fit(min_width, width, max_width)
    new_height = scale_to_fit(min_height, height, max_height)

    if new_width.to_f / width > new_height.to_f / height
      scale_by_width(width, new_width)
    elsif new_height > 0
      scale_by_height(height, new_height)
    end
  end

  def gm_crop_param
    if max_width or max_height
      format('%sx%s', max_width || 10_000_000, max_height || 10_000_000)
    else
      nil
    end
  end

  protected

  def scale_to_fit(min, current, max)
    if min && current < min
      min    # scale bigger
    elsif max && current > max
      max    # scale smaller
    else
      0
    end
  end

  def scale_by_width(old_width, new_width)
    if old_width < new_width
      format('%sx^', new_width) # bigger
    elsif old_width == new_width
      nil
    else
      format('%sx', new_width)  # smaller
    end
  end

  def scale_by_height(old_height, new_height)
    if old_height < new_height
      format('x%s^', new_height) # bigger
    elsif old_height == new_height
      nil
    else
      format('x%s', new_height)  # smaller
    end
  end
end
