require 'test_helper'

class Wiki::DiffsControllerTest < ActionController::TestCase
  fixtures :pages, :users, 'user/participations', :wikis, :groups

  def test_diff
    login_as :orange

    (1..5).zip(%i[orange yellow blue red purple]).each do |i, user|
      pages(:wiki).data.update_section!(:document, users(user), i, format('text %d for the wiki', i))
    end

    get :show, wiki_id: pages(:wiki).data_id, id: '4-5'
    assert_response :success

    assert_equal assigns(:wiki).versions.reload.find_by_version(4).body_html, assigns(:old).body_html
    assert_equal assigns(:wiki).versions.reload.find_by_version(5).body_html, assigns(:new).body_html
    assert assigns(:diff).length > 10, 'difftext should contain something substantial'
  end
end
