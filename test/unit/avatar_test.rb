require File.dirname(__FILE__) + '/test_helper'

class AvatarTest < ActiveSupport::TestCase

  def test_resize_image
    avatar = Avatar.create!(:image_file => upload_data('bee.jpg'))
    blob = avatar.resize('medium');
    assert_not_nil blob
  end
end
