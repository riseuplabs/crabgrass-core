require 'test_helper'

class Pages::AssetsControllerTest < ActionController::TestCase
  fixtures :users, :groups, :memberships

  def setup
    @page = FactoryGirl.create :page, :created_by => users(:blue)
    login_as :blue
  end

  def test_index
    get :index, :page_id => @page.id
    assert_response :success
  end

  def test_upload_ready_for_progress_bar
    get :index, :page_id => @page.id
    assert_not_nil upload_id = assigns['image_upload_id'],
      "index action should include image_upload-id"
    assert_select '.progress[style="display: none;"]', 1,
        "a hidden progress bar should be included" do
      assert_select '.bar[style="width: 10%;"]', "0 %",
        "the progress bar should be 10% filled"
      end
    assert_select 'form[action*="X-Progress-ID"]' do
      assert_select 'input[type="hidden"][value="' + upload_id + '"]'
    end
  end

  def test_create_zip
    login_as :blue
    assert_difference '@page.assets.count' do
      post :create, :page_id => @page.id,
       :assets => [upload_data('subdir.zip')]
    end
    assert_equal 'image/jpeg', Asset.last.content_type
    assert_equal @page.id, Asset.last.page_id
    assert_equal "fox", Asset.last.basename
  end

  def test_may_create
    @page.add(groups(:rainbow), :access => :edit).save!
    @page.save!
    login_as :red
    assert_difference '@page.assets.count' do
      post :create, :page_id => @page.id, :assets => [upload_data('photo.jpg')]
    end
    assert_equal @page.id, Asset.last.page_id
  end

  def test_may_not_create
    @page.add(groups(:rainbow), :access => :view).save!
    @page.save!
    login_as :red
    assert_no_difference '@page.assets.count' do
      post :create, :page_id => @page.id, :assets => [upload_data('photo.jpg')]
      assert_permission_denied
    end
  end

  def test_destroy
    login_as :blue
    assert_difference '@page.assets.count', -1 do
      delete :destroy, :id => @asset.id, :page_id => @page.id
    end
  end

end
