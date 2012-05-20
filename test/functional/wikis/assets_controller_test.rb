require File.dirname(__FILE__) + '/../test_helper'

class Wikis::AssetsControllerTest < ActionController::TestCase

  def setup
    @user = User.make
    @group = Group.make
    @group.add_user!(@user)
    @wiki = @group.profiles.public.create_wiki :body => 'test'
    @old_image = Asset.build :uploaded_data => upload_data('bee.jpg')
    @old_image.create_page(@user, @group)
    @old_image.save
  end

  def test_new
    login_as @user
    assert_permission :may_edit_wiki? do
      get :new, :wiki_id => @wiki.id
    end
    assert_response :success
    assert_equal [@old_image], assigns('images')
  end

  def test_create
    login_as @user
    assert_permission :may_edit_wiki? do
      assert_difference 'Asset.count' do
        assert_difference '@group.pages.count' do
          sleep 1 # make sure most recent always works
          post :create, :wiki_id => @wiki.id,
            :asset => {:uploaded_data => upload_data('gears.jpg')}
        end
      end
    end
    assert_equal [Asset.last, @old_image], assigns('images')
  end
end
