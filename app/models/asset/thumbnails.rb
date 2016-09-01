module Asset::Thumbnails
  extend ActiveSupport::Concern

  included do
    class_attribute :class_thumbdefs
  end


  module ClassMethods
    def define_thumbnails(thumbnail_definitions={})
      # inherit thumbdefs from super class but modify a dup
      # so changes to not get pushed up.
      # See http://martinciu.com/2011/07/difference-between-class_inheritable_attribute-and-class_attribute.html
      self.class_thumbdefs = (class_thumbdefs || {}).dup
      thumbnail_definitions.each do |name, data|
        self.class_thumbdefs[name] = Asset::ThumbnailDefinition.new(name, data).freeze
      end
      self.class_thumbdefs.freeze
    end

    # true if any thumbnails are defined for the class
    def thumbable?
      self.class_thumbdefs.any?
    end
  end

  #
  # Allow for dynamic reassignment of thumbdefs for instances
  # This is useful when we change Asset type depending on content type.
  #
  def thumbdefs
    @thumbdefs || class_thumbdefs
  end
  def thumbdefs=(newdefs)
    @thumbdefs = newdefs
  end

  # returnes true if the thumbnail file has been generated
  def thumbnail_exists?(name)
    fname = path.private_filename thumbnail_filename(name)
    File.exist?(fname) and File.size(fname) > 0
  end

  # returns the thumbnail with 'name'
  def thumbnail(name, include_failures=false)
    return unless name
    name = name.to_s
    thumbnails.detect{|thumb|thumb.name == name and (thumb.ok? or include_failures)}
  end

  # returns the relative filename of a thumbnail given its name
  # thumbnail filenames always have a "_" (THUMBNAIL_SEPARATOR)
  # eg. thumbnail_filename(:small) --> "myfile_small.jpg"
  def thumbnail_filename(name)
    return name if name =~ /#{THUMBNAIL_SEPARATOR}/  # we might have been passed an already resolved thumbnail_filename
    thumbdef = name if name.is_a? Asset::ThumbnailDefinition
    thumbdef ||= thumbdefs[name.to_sym]
    if thumbdef.nil?
      return "#{self.basename}#{THUMBNAIL_SEPARATOR}#{name}.#{name}"
    elsif thumbdef.proxy and thumbdef.mime_type == self.content_type
      self.filename
    else
      "#{self.basename}#{THUMBNAIL_SEPARATOR}#{thumbdef.name}.#{thumbdef.ext}" if thumbdef
    end
  end

  # populate self.thumbnails
  def create_thumbnail_records
    thumbdefs.each do |name,thumbdef|
      create_or_update_thumbnail(thumbdef)
    end
  end

  # actually render the thumbnails
  def generate_thumbnails(force = false)
    thumb_done = {}
    thumbnails.each do |thumb|
      thumb.generate(force)
    end
    if versions.latest
      # might as well update the thumbnails of our corresponding version
      # while we are at it.
      versions.latest.clone_files_from(self)
    end
  end

  # force the generation of thumbnails, even if they already exist
  def generate_thumbnails!
    generate_thumbnails(true)
  end

  # returns true if this asset may have a thumbnail of dest_type
  def may_thumbnail?(dest_type='image/jpg')
    Media.may_produce?(content_type, dest_type)
  end

  # creates the thumbnail database records for the particular thumbdef
  def create_or_update_thumbnail(thumbdef)
    return unless may_thumbnail?(thumbdef.mime_type)

    thumb = Thumbnail.find_or_init thumbdef.name, self.id, 'Asset'
    # ^^^ self.type is on purpose (rather than self.class) because we
    # may have modified self.type
    thumb.content_type        = thumbdef.mime_type
    thumb.filename            = thumbnail_filename(thumbdef)
    thumb.width, thumb.height = guess_dimensions(thumbdef.size)
    thumb.save!
  end

  # predict the dimensions of a thumbnail before the thumbnail is actually rendered
  def guess_dimensions(size)
    return unless self.height and self.width and size
    target_width, target_height = size.split /[x>]/
    if size =~ />$/
      ratio_width  = target_width.to_f/self.width
      ratio_height = target_height.to_f/self.height
      ratio = [ratio_width, ratio_height, 1].min
      return [ (self.width * ratio).round, (self.height * ratio).round ]
    else
      return [target_width, target_height]
    end
  end

  # create thumbnail database records in self that are the
  # same as the ones in orig_model (with a different parent)
  # only called on Asset::Versions
  def clone_thumbnails_from(orig_model)
    orig_model.thumbnails.each do |thumbnail|
      t = Thumbnail.create thumbnail.attributes.merge(parent_id: self.id, parent_type: 'Asset::Version')
    end
  end

end

