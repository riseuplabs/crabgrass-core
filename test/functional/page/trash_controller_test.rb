require 'test_helper'

class Page::TrashControllerTest < ActionController::TestCase
  def setup
    @user = FactoryBot.create(:user)
    @page = FactoryBot.create(:page, owner: @user)

    assert @user, 'no user!'
    assert @page, 'no page!'
  end

  def test_destroy
    login_as @user
    xhr :post, :update, page_id: @page.id, type: :destroy
    assert_response :success
    assert_equal 0, Page.where(id: @page.id).count
  end

  def test_delete
    login_as @user
    xhr :post, :update, page_id: @page.id, type: :delete
    assert_response :success
    assert Page.where(id: @page).first.deleted?
  end

  def test_undelete
    @page.delete
    login_as @user
    xhr :post, :update, page_id: @page.id, type: :undelete
    assert_response :success
    assert !Page.where(id: @page).first.deleted?
  end
end
