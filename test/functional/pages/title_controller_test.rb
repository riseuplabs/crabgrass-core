require_relative '../../test_helper'

class Pages::TitleControllerTest < ActionController::TestCase

  def setup
    @user = FactoryGirl.create(:user)
    @page = FactoryGirl.create(:page, :owner => @user)

    assert @user, 'no user!'
    assert @page, 'no page!'
  end

  def test_edit_title
    login_as @user
    xhr :get, :edit, :page_id => @page.id
    assert_template 'pages/title/edit'
  end

  def test_update_title
    login_as @user
    xhr :put, :update, page_id: @page.id, page: { title: "sunset" }
    assert_equal @page.reload.title, 'sunset'
    assert_template 'pages/title/update'
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
    assert_template 'pages/title/update'
  end

end

