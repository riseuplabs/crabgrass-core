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
class Picture
  #
  # Picture::Geometry class
  #
  # We ensure that the attributes consists only of integers or nil.
  # This is important, because we might have got the geometry source
  # from a url.
  #
  class Geometry

    attr_accessor :min_width, :max_width, :min_height, :max_height

    def initialize(source=nil)
      set_limits *limits_from_source(source)
    end

    def limits_from_source(source=nil)
      case source
      when Hash
        [source[:min_width], source[:max_width], source[:min_height], source[:max_height]]
      when  Array
        source
      when String
        source.split('-')
      else
        []
      end
    end

    def set_limits(minw=nil, maxw=nil, minh=nil, maxh=nil)
      self.min_width  = minw.to_i if minw
      self.min_width  = nil       if self.min_width == 0
      self.max_width  = maxw.to_i if maxw
      self.max_width  = nil       if self.max_width == 0
      self.min_height = minh.to_i if minh
      self.min_height = nil       if self.min_height == 0
      self.max_height = maxh.to_i if maxh
      self.max_height = nil       if self.max_height == 0
    end

    def empty?
      not any?
    end

    def any?
      min_width or max_width or min_height or max_height
    end

    def to_s
      empty? ? 'full' : to_a.join('-')
    end

    def to_a
      empty? ? [] : [min_width||0, max_width||0, min_height||0, max_height||0]
    end



  end
end
