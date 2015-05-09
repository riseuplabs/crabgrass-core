require 'test_helper'

class Pages::ParticipationsControllerTest < ActionController::TestCase

  def setup
    @user = FactoryGirl.create :user
    @page = FactoryGirl.create(:page)
    @upart = @page.add(@user, access: :view)
    @upart.save
    login_as @user
  end

  def test_star
    xhr :post, :update, page_id: @page, id: @upart, star: true
    assert @upart.reload.star
  end

  def test_watch
    xhr :post, :update, page_id: @page, id: @upart, watch: true
    assert @upart.reload.watch
  end

  def test_prevent_increasing_access
    xhr :post, :update, page_id: @page, id: @upart, access: :admin
    assert_equal :view, @upart.reload.access_sym
  end
end

