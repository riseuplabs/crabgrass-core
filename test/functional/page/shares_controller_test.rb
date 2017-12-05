require 'test_helper'

class Page::SharesControllerTest < ActionController::TestCase
  def setup
    @owner = FactoryBot.create(:user)
    @recipient = FactoryBot.create(:user)
  end

  def test_show_share_popup
    login_as @owner
    page = FactoryBot.create :page, created_by: @owner
    xhr :get, :show, page_id: page.id, mode: 'share'
    assert_response :success
  end

  def test_show_notify_popup
    login_as @owner
    page = FactoryBot.create :page, created_by: @owner
    xhr :get, :show, page_id: page.id, mode: 'notify'
    assert_response :success
  end

  def test_autocomplete_user_for_new_page
    login_as @owner
    xhr :post, :update, recipient: { name: @recipient.name, access: :admin },
                        page_id: '0',
                        add: true,
                        mode: 'share',
                        format: :js
    assert @response.body.include?(@recipient.login)
    assert_template partial: '_add_recipient'
  end

  def test_share_page_with_multiple_recipients
    page = FactoryBot.create :page, created_by: @owner
    login_as @owner
    admin = { access: 'admin' }
    assert_difference 'Page::History.count', 2 do
      xhr :post, :update, share_button: true,
                          recipients: { blue: admin, animals: admin, contributors: '0' },
                          page_id: page.id,
                          mode: 'share',
                          format: :js
    end
  end

  def test_share_page_with_group
    page = FactoryBot.create :page, created_by: @owner
    login_as @owner
    admin = { access: 'admin' }
    assert_difference 'Page::History.count' do
      xhr :post, :update, share_button: true,
                          recipients: { animals: admin },
                          page_id: page.id,
                          mode: 'share',
                          format: :js
    end
    assert_equal 'page_history_granted_group_full_access',
                 Page::History.last.description_key
  end

  def test_share_page_with_user
    page = FactoryBot.create :page, created_by: @owner
    login_as @owner
    admin = { access: 'admin' }
    assert_difference 'Page::History.count' do
      xhr :post, :update, share_button: true,
                          recipients: { blue: admin },
                          page_id: page.id,
                          mode: 'share',
                          format: :js
    end
    assert_equal 'page_history_granted_user_full_access',
                 Page::History.last.description_key
  end
end
