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
    def to_size(orig_size)
      width = orig_size[0]
      height = orig_size[1]
      scale_width = nil
      scale_height = nil
      new_width = nil
      new_height = nil

      # scale width?
      if min_width && width < min_width
        scale_width = min_width.to_f / width   # scale bigger
        new_width = min_width
      elsif max_width && width > max_width
        scale_width = max_width.to_f / width   # scale smaller
        new_width = max_width
      end

      # scale height?
      if min_height && height < min_height
        scale_height = min_height.to_f / height  # scale bigger
        new_height = min_height
      elsif max_height && height > max_height
        scale_height = max_height.to_f / height  # scale smaller
        new_height = max_height
      end

      # scale in both dimensions
      if scale_width && scale_height
        # if scale both bigger
        if scale_width > 1 && scale_height > 1
          # scale by one that needs to grow more
          if scale_width > scale_height
            "%sx^" % new_width   # bigger
          else
            "x%s^" % new_height  # bigger
          end
          # if scale both smaller
        elsif scale_width < 1 && scale_height < 1
          # scale by one that needs to shrink the least
          if scale_width > scale_height
            "%sx" % new_width  # smaller
          else
            "x%s" % new_height # smaller
          end
          # if scale width bigger AND scale height smaller
        elsif scale_width > 1
          "%sx^" % new_width  # bigger
          # if scale height bigger AND scale width smaller
        elsif scale_height > 1
          "x%s^" % new_height # bigger
        end
        # scale in one dimension
      elsif scale_width
        if scale_width > 1
          "%sx^" % new_width # bigger
        else
          "%sx" % new_width  # smaller
        end
      elsif scale_height
        if scale_height > 1
          "x%s^" % new_height # bigger
        else
          "x%s" % new_height  # smaller
        end
      end
    end

    def to_crop
      if max_width or max_height
        "%sx%s" % [max_width||10000000, max_height||10000000]
      else
        nil
      end
    end


  end
end
