#
# Picture -- a simple record to hold a single image file.
#
# We have three models that handle image files: Asset, Avatar, and
# Picture. Why so many? They are each pretty different.
#
#   Asset   -- for when you need versioning and thumbnails
#              of any content type.
#              Permissions: YES
#
#   Avatar  -- for square icons of users and groups.
#              Permissions: NO
#
#   Picture -- when you want a simple image and want to be able to
#              display it with many sizing options.
#              Permissions: maybe eventually.
#
# STORAGE
#
# Picture.dimensions stores, in a hash, the height and width of all
# the resized copies of the image, keyed on the geometry constraints
# that produced the resized copy.
#
# For example:
#
#  { [a,b,c,d] => [width, height],
#    [a,b,c,d] => [width, height] }
#
# where a,b,c,d is the value of:
#
#  min_width, max_width, min_height, max_height
#
# Suppose picture.dimensions looks like this:
#
#  {'full' => [256,256], [100,100,0,400] => [100,400]}
#
# This corresponds to files stored like so:
#
#  0000/0004/full.jpg
#  0000/0004/100-100-0-400.jpg
#
# The values are integers, and not strings.
#
# TODO: graceful handling of corrupted images
#

require 'open-uri'     # required for open(url).read
require 'fileutils'    # required for mkdir and rmdir
require 'pathname'     # required for relative paths

MAX_HEIGHT = 1024
MAX_WIDTH = 1024

class Picture < ActiveRecord::Base

  URL_ROOT = PICTURE_PUBLIC_STORAGE.sub(File.join(Rails.root,'public'),'')

  serialize :dimensions
  after_destroy :destroy_files
  after_create :save_uploaded_file

  #
  # the private filesystem path of this picture
  # e.g. rails_root/assets/pictures/0000/0004/full.jpg
  #
  def private_file_path(geometry=nil)
    storage.private_path(geometry)
  end

  #
  # the public filesystem path of this picture
  #
  def public_file_path(geometry=nil)
    storage.public_path(geometry)
  end

  #
  # the relative url path for this picture
  #
  def url(geometry=nil)
    storage.url(geometry)
  end

  #
  # returns [width, height] for a given geometry
  #
  def size(geometry=nil)
    dimensions[geometry.to_s] ||= storage.dimensions(geometry)
  end

  #
  # Adds a new geometry definition to this Picture, and saves
  # a copy of the resized image.
  #
  # You must add a geometry definition before you can display
  # a picture resized to a given dimensions.
  #
  def add_geometry!(geometry)
    if geometry.present?
      geometry = to_geometry(geometry)
      geo_key = geometry.to_s
      self.dimensions ||= {}
      if dimensions[geo_key].nil?
        resize(geometry)
        size(geometry) # stores size in dimensions
        save!
      end
    end
  end

  #
  # removes a geometry from this picture, and the associated image files
  #
  def remove_geometry!(geometry)
    geometry = to_geometry(geometry)
    if geometry.any?
      geo_key = geometry.to_s
      self.dimensions ||= {}
      if dimensions[geo_key].any?
        destroy_file(geometry)
        dimensions.delete(geo_key)
        save!
      end
    end
  end

  #
  # This method does three things:
  # (1) Adds the geometry to this picture's list of dimensions
  # (2) Creates the public and private storage directories for this picture.
  # (3) Renders the image matching geometry
  #
  # If any of those things exists or are already set up, this method
  # skips it.
  #
  def render!(geometry)
    # ensure dimension record exists
    add_geometry!(geometry)
    render(geometry)
  end

  #
  # like render!, but will not add a new geometry
  #
  def render(geometry)
    # ensure the file has been rendered
    unless File.exists?(storage.private_path(geometry))
      resize(geometry)
    end
    # ensure symlink to public dir exists
    storage.add_symlink # for now, all Pictures are public.
  end

  #
  # for uploading the image.
  #
  # The uploaded_file may be one of three types:
  #
  # (1) an empty String  (if form was empty)
  # (2) UploadedStringIO (if the file is small)
  # (3) UploadedTempfile (if file is big)
  #
  def upload=(uploaded_file)
    return if uploaded_file.is_a?(String) and uploaded_file.empty?
    return if uploaded_file.original_filename.empty?

    @uploaded_file = uploaded_file
    self.content_type = uploaded_file.content_type ||
      Media::MimeType.mime_type_from_extension(uploaded_file.original_filename)
  end

  ##
  ## PRIVATE METHODS
  ##

  private

  #
  # Convert geometry specified as Hash, Array, or String into Geometry.
  #
  def to_geometry(geometry)
    geometry.is_a?(Geometry) ? geometry : Geometry.new(geometry)
  end

  def storage
    @storage ||= Storage.new(self)
  end

  #
  # after_create callback.
  #
  # We wait until after the Picture is created to actually capture
  # and store the uploaded file. Otherwise, we end up saving files
  # even for pictures we never save.
  #
  def save_uploaded_file
    storage.allocate_directory
    File.open(private_file_path, "wb") do |f|
      f.write(@uploaded_file.read)
    end
    # save the height & width for the 'full' image (indexed as 'full' in geometry hash)
    add_geometry! nil
  end


  #
  # Destroys the all files for this picture
  #
  def destroy_files
    storage.destroy_files
  end

  #
  # Destroys a single rendered file
  #
  def destroy_file(geometry)
    storage.destroy_file(geometry)
  end



  #
  # render a new file with the specified geometry
  #
  def resize(geometry)
    geometry = to_geometry(geometry)
    input_path = private_file_path
    output_path = storage.private_path(geometry)
    status = GraphicsMagickTransmogrifier.new(
      :input_file => input_path,
      :output_file => output_path,
      :size => geometry.gm_size_param_from(self.size),
      :crop => geometry.gm_crop_param
    ).try.run
    if status != :success
      raise ErrorMessage.new('invalid image')
    end
  end

end


