require 'test_helper'

class Wiki::AssetsControllerTest < ActionController::TestCase
  def setup
    @user = FactoryBot.create(:user)
    @group = FactoryBot.create(:group)
    @group.add_user!(@user)
    @wiki = @group.profiles.public.create_wiki body: 'test'
    @old_image = Asset.build uploaded_data: upload_data('bee.jpg')
    @old_image.create_page(@user, @group)
    @old_image.save
  end

  def test_new
    login_as @user
    get :new, wiki_id: @wiki.id
    assert_response :success
    assert_equal [@old_image], assigns('images')
  end

  def test_create
    login_as @user
      assert_difference 'Asset.count' do
        assert_difference '@group.pages.count' do
          sleep 1 # make sure most recent always works
          xhr :post, :create, wiki_id: @wiki.id,
                              asset: { uploaded_data: upload_data('gears.jpg') }
        end
    end
    assert_equal [Asset.last, @old_image], assigns('images')
  end
end
