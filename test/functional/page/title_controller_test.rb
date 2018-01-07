require 'test_helper'

class Page::TitleControllerTest < ActionController::TestCase
  def setup
    @user = FactoryBot.create(:user)
    @page = FactoryBot.create(:page, owner: @user)

    assert @user, 'no user!'
    assert @page, 'no page!'
  end

  def test_edit_title
    login_as @user
    xhr :get, :edit, page_id: @page.id
    assert_template 'page/title/edit'
  end

  def test_edit_title_not_allowed
    login_as users(:blue)
    assert_permission_denied do
      xhr :get, :edit, page_id: @page.id
    end
  end

  def test_update_title
    login_as @user
    xhr :put, :update, page_id: @page.id, page: { title: 'sunset' }
    assert_equal @page.reload.title, 'sunset'
    assert_template 'page/title/update'
  end

  def test_update_title_not_allowed
    login_as users(:blue)
    assert_permission_denied do
      xhr :put, :update, page_id: @page.id, page: { title: 'sunset' }
    end
  end

  def test_update_summary_and_name
    login_as @user
    xhr :put, :update, page_id: @page.id, page: {
      title: @page.title,
      summary: 'new-summary',
      name: 'new-name'
    }
    assert_equal @page.reload.summary, 'new-summary'
    assert_equal @page.reload.name, 'new-name'
    assert_template 'page/title/update'
  end
end
