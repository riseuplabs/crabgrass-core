require 'test_helper'

class Pages::ParticipationsControllerTest < ActionController::TestCase

  def setup
    @user = FactoryGirl.create :user
    @page = FactoryGirl.create :page
    @upart = @page.add(@user, access: :admin)
    @upart.save
    login_as @user
  end

  def test_star
    assert_difference 'PageHistory::AddStar.count' do
      post :update, page_id: @page, id: @upart, star: true
    end
    assert @upart.reload.star
  end

  def test_watch
    assert_difference 'PageHistory::StartWatching.count' do
      post :update, page_id: @page, id: @upart, watch: true
    end
    assert @upart.reload.watch
  end

  def test_prevent_increasing_access
    @upart.access = :view
    @upart.save
    assert_no_difference 'PageHistory.count' do
      post :update, page_id: @page, id: @upart, access: :admin
    end
    assert_equal :view, @upart.reload.access_sym
  end

  def test_destroy_user_participation
    other_user = FactoryGirl.create :user
    other_upart = @page.add(other_user, access: :view)
    other_upart.save
    assert_difference 'PageHistory.count' do
      post :update, page_id: @page, id: other_upart, access: :remove
    end
  end

  def test_destroy_group_participation
    group = FactoryGirl.create :group
    gpart = @page.add(group, access: :view)
    gpart.save
    assert_difference 'PageHistory.count' do
      post :update, page_id: @page, id: gpart, group: true, access: :remove
    end
  end
end

