require 'test_helper'

class GalleryControllerTest < ActionController::TestCase
  def setup
    # let's make some gallery
    # there are no galleries in fixtures yet.
    #
    @gallery = Gallery.create! title: 'gimme pictures', user: users(:blue)
    @asset = @gallery.add_image! uploaded_data: upload_data('photo.jpg')
    users(:blue).updated(@gallery)
  end

  def test_show
    login_as :blue
    get :show, params: { id: @gallery.id }
    assert_response :success
    assert_not_nil assigns(:images)
  end

  def test_show_empty
    login_as :blue
    gallery = Gallery.create!(user: users(:blue),
                              title: 'Empty Gallery')
    get :show, params: { id: gallery.id }
    assert_response :redirect
    assert_redirected_to @controller.send(:page_url, gallery, action: 'edit')
  end

  def test_edit
    login_as :blue
    get :edit, params: { id: @gallery.id }
    assert_response :success
  end
end
