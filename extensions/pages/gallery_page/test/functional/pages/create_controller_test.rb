require File.dirname(__FILE__) + '/../../../../../../test/test_helper'

class Pages::CreateControllerTest < ActionController::TestCase
  fixtures :users

# this controller does not really even exist yet:
  #azul: I think it does - at least there is some base page magic
  def test_create
    login_as :blue

    assert_difference 'Gallery.count' do
      post :create, :type => Gallery.param_id, :page => {:title => 'pictures'}, :assets => [upload_data('photo.jpg')]
    end

    assert_not_nil assigns(:page)
    assert_equal 1, assigns(:page).images.count
    assert_not_nil assigns(:page).page_terms
    assert_equal assigns(:page).page_terms, assigns(:page).images.first.page_terms
  end

  def test_create_from_zip
    login_as :blue

    assert_difference 'Gallery.count' do
      post :create, :type => Gallery.param_id, :page => {:title => 'pictures 2'},
           :assets => [upload_data('photo.jpg'), upload_data('subdir.zip')]
    end

    assert_not_nil assigns(:page)
    assert_equal 2, assigns(:page).images.count
  end
end
