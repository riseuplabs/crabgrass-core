require 'test_helper'

class CreateAssetPageControllerTest < ActionController::TestCase


  def setup
    setup_assets
  end

  def teardown
    teardown_assets
  end

  def test_new
    login_as :gerrard

    get 'new', page_id: 'me'
  end

  def test_create_requires_data
    login_as :gerrard

    assert_no_difference 'Asset.count' do
      assert_no_difference 'Page.count' do
        post 'create', page_id: 'me',
          page: {title: 'test'},
          asset: {uploaded_data: nil}
        assert_equal :error, flash[:messages].first[:type],
          "shouldn't be able to create an asset page with no asset"
      end
    end
  end

  def test_create
    login_as :gerrard
    assert_difference 'Thumbnail.count', 6,
      "image file should generate 6 thumbnails" do
      post 'create', page_id: 'me',
        page: {title: "title", summary: ""},
        asset: {uploaded_data: upload_data('photo.jpg')}
      assert_response :redirect
    end
  end

  def test_create_with_xcf
    login_as :gerrard
    assert_difference 'Thumbnail.count', 0,
      "xcf currently does not generate thumbnails" do
      post 'create', page_id: 'me',
        page: {title: "title", summary: ""},
        asset: {uploaded_data: upload_data('image.xcf')}
      assert_response :redirect
    end
  end

  def test_create_in_group
    login_as :blue

    post 'create', page_id: 'me',
      page: {title: "title", summary: ""},
      asset: {uploaded_data: upload_data('photo.jpg')},
      recipients: {'rainbow' => {access: 'admin'}}
    assert_equal [groups(:rainbow)], assigns(:page).groups,
      "asset page should belong to rainbow group"
  end

end
