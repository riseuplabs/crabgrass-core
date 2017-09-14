require 'test_helper'

class Page::CreateControllerTest < ActionController::TestCase
  def setup
    @user = FactoryGirl.create(:user)
  end

  def test_new_page_view
    login_as @user
    get :new, owner: 'me', type: 'wiki'
    # if the owner is the current user we do not set it.
    assert_nil assigns(:owner)
  end

  def test_new_group_page_view
    login_as users(:blue)
    get :new, owner: 'rainbow', type: 'wiki'
    # if the owner is the current user we do not set it.
    assert_equal groups(:rainbow), assigns(:owner)
  end

  def test_create_page_for_myself
    login_as @user
    assert_difference 'WikiPage.count' do
      post :create,
           owner: 'me',
           page: { title: 'title' },
           type: 'wiki',
           page_type: 'WikiPage'
    end
    assert_equal @user, Page.last.owner
    assert Page.last.users.include? @user
  end

  def test_create_page_for_group
    @group = FactoryGirl.create(:group)
    login_as @user
    assert_difference 'WikiPage.count' do
      post :create,
           owner: @group.name,
           page: { title: 'title' },
           type: 'wiki',
           page_type: 'WikiPage'
    end
    assert_equal @group, Page.last.owner
    assert Page.last.users.include? @user
  end

  def test_create_same_name
    login_as @user

    data_ids = []
    page_ids = []
    page_urls = []
    3.times do
      post 'create',
           owner: @user,
           page: { title: 'dupe' },
           type: 'ranked-vote',
           page_type: 'RankedVotePage'
      page = assigns(:page)

      assert_equal 'dupe', page.title
      assert_not_nil page.id

      # check that we have:
      # a new ranked vote
      assert !data_ids.include?(page.data.id)
      # a new page
      assert !page_ids.include?(page.id)
      # a new url
      assert !page_urls.include?(page.name_url)

      # remember the values we saw
      data_ids << page.data.id
      page_ids << page.id
      page_urls << page.name_url
    end
  end

  def test_create_shared_with_group
    login_as @user
    @group = FactoryGirl.create(:group)
    @group.add_user! @user

    post 'create', page_id: 'me', type: 'discussion',
                   page: { title: 'title', summary: '' },
                   recipients: { @group.name => { access: 'admin' } }
    assert_equal [@group], assigns(:page).groups,
                 'page should belong to rainbow group'
  end
end
