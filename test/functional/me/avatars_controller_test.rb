require 'test_helper'

class Me::AvatarsControllerTest < ActionController::TestCase
  def setup
    @user = FactoryBot.create(:user)
  end

  def test_user_could_upload_avatar_from_file
    login_as @user
    assert_nil @user.avatar
    user_uploads_avatar

    assert_redirected_to me_settings_url
    assert_instance_of Avatar, @user.avatar
  end

  def test_user_could_remove_uploaded_avatar
    login_as @user
    user_uploads_avatar
    assert_not_nil @user.avatar

    delete :destroy

    assert_redirected_to me_settings_url
    assert_nil @user.avatar
  end

  private

  def user_uploads_avatar
    file_path = File.join('files', 'photo.jpg')
    file = fixture_file_upload(file_path, 'image/jpeg')

    post :create, avatar: { image_file: file, image_file_url: '' }
  end
end
