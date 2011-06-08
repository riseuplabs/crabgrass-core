#
# Avatar -- the little icons for users and groups
#
#  create_table "avatars", :force => true do |t|
#    t.binary  "image_file_data"
#    t.boolean "public",          :default => false
#  end
#
# also defined:
#
#   avatar.image_file
#
# Which one do you use? Always use image_file to set the data, and
# always use image_file_data to retreive the image data.
#

require 'open-uri'

class Avatar < ActiveRecord::Base

  DEFAULT_DIR = "#{RAILS_ROOT}/public/images/default"

  SIZES = Hash.new(32).merge(
    'tiny'   => 16,
    'xsmall' => 22,
    'small'  => 32,
    'medium' => 48,
    'large'  => 64,
    'xlarge' => 96,
    'huge'   => 202
  ).freeze

  attr_accessor :image_file, :image_file_url

  def self.pixels(size)
    size = SIZES[size.to_s]
    "#{size}x#{size}"
  end

  #
  # return binary data of the image at the specified size
  #
  def resize(size, content_type = 'image/jpeg')
    resize_from_blob(self.image_file_data, size, content_type)
  end

  def image_file=(file)
    # mime_type = Asset.mime_type_from_data(data) we don't do this yet :(
    self.image_file_data = if file.path
      resize_from_file(file.path, 'huge')
    else
      resize_from_blob(file.read, 'huge')
    end
  end

  def image_file_url=(url)
    if url.any?
      begin
        self.image_file_data = resize_from_blob(open(url).read, 'huge') # from 'open-uri'
      rescue Exception => exc
        raise ErrorMessage.new(exc.to_s)
      end
    end
  end

  private

  def resize_from_blob(blob, size, content_type = 'image/jpeg')
    if blob.nil?
      return IO.read(default_file(size))
    else
      Media::TempFile.open(blob) do |image_file|
        return resize_from_file(image_file.path, size, content_type)
      end
    end
  end

  def resize_from_file(filename, size, content_type = 'image/jpeg')
    dimensions = Avatar.pixels(size) + '^' # ie '32x32^', forces each dimension to be at least 32px
    crop = Avatar.pixels(size)
    if !File.exists?(filename)
      IO.read(default_file(size))
    else
      Media::TempFile.open(nil,content_type) do |dest_file|
        status = GraphicsMagickTransmogrifier.new(:input_file => filename, :output_file => dest_file, :size => dimensions, :crop => crop).try.run
        if status == :success
          return IO.read(dest_file.path)
        else
          raise ErrorMessage.new('invalid image')
        end
      end
    end
  end

  private

  def default_file(size)
    DEFAULT_DIR + '/' + SIZES[size].to_s + '.jpg'
  end

end

