require_relative '../../test_helper'

class Pages::SharesControllerTest < ActionController::TestCase

  def setup
    @owner = FactoryGirl.create(:user)
    @recipient = FactoryGirl.create(:user)
  end

  def test_autocomplete_user_from_new_page
    login_as @owner
    xhr :post, :update, recipient: {name: @recipient.name, access: :admin},
      page_id: "0",
      add: true,
      mode: 'share',
      format: :js
    assert @response.body.include?(@recipient.login)
    assert_template :partial => '_add_recipient'
  end
end
