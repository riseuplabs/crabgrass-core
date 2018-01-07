require 'test_helper'

class Page::TrashControllerTest < ActionController::TestCase
  def setup
    @user = users(:red)
    @page = FactoryBot.create(:page, owner: @user)

    assert @user, 'no user!'
    assert @page, 'no page!'
  end

  def test_edit
    login_as @user
    xhr :get, :edit, page_id: @page
    assert_response :success
  end

  def test_edit_no_allowed
    login_as users(:blue)
    assert_permission_denied do
      xhr :get, :edit, page_id: @page
    end
  end

  def test_destroy
    login_as @user
    xhr :post, :update, page_id: @page.id, type: :destroy
    assert_response :success
    assert_equal 0, Page.where(id: @page.id).count
  end

  def test_destroy_not_allowed
    login_as users(:blue)
    assert_permission_denied do
      xhr :post, :update, page_id: @page.id, type: :destroy
    end
    assert_equal 1, Page.where(id: @page.id).count
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
