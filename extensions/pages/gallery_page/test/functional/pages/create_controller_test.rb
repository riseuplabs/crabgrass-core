require 'test_helper'

class Pages::CreateControllerTest < ActionController::TestCase
  fixtures :users

  def setup
    skip 'you cannot upload initial images during gallery creation right now.'
  end

  def test_create
    login_as :blue

    assert_difference 'Gallery.count' do
      post :create, type: Gallery.param_id, page: {title: 'pictures'}, assets: [upload_data('photo.jpg')]
    end

    assert_not_nil assigns(:page)
    assert_equal 1, assigns(:page).images.count
    assert_not_nil assigns(:page).page_terms
    assert_equal assigns(:page).page_terms, assigns(:page).images.first.page_terms
  end

  def test_create_from_zip
    login_as :blue

    assert_difference 'Gallery.count' do
      post :create, type: Gallery.param_id, page: {title: 'pictures 2'},
           assets: [upload_data('photo.jpg'), upload_data('subdir.zip')]
    end

    assert_not_nil assigns(:page)
    assert_equal 2, assigns(:page).images.count
  end
end
