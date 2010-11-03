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

class Avatar < ActiveRecord::Base

  SIZES = Hash.new(32).merge(
    'tiny' => 16,
    'xsmall' => 22,
    'small' => 32,
    'medium' => 48,
    'large' => 60,
    'xlarge' => 96,
    'huge' => 202
  ).freeze

  acts_as_fleximage do
    default_image_path "public/images/default/202.jpg"
    require_image false
    output_image_jpg_quality 95
#    image_directory 'public/images/uploaded'  \ how do we migrate
#    image_storage_format :png                 / to using these options?
    preprocess_image do |image|
      image.resize '202x202', :crop => true
    end
  end

  def self.pixels(size)
    size = SIZES[size.to_s]
    "#{size}x#{size}"
  end

end

