require 'test_helper'

class Wiki::WikisControllerTest < ActionController::TestCase
  fixtures :pages, :users, :user_participations, :wikis

  def test_edit
    login_as :orange
    pages(:wiki).add users(:orange), access: :edit
    pages(:wiki).add users(:blue), access: :edit

    get :edit, id: pages(:wiki).data_id
    assert_equal [], assigns(:wiki).sections_open_for(users(:blue)), "editing a wiki should lock it"

    assert_equal users(:orange), assigns(:wiki).locker_of(:document), "should be locked by orange"

    assert_no_difference 'pages(:wiki).updated_at' do
      put :update, id: pages(:wiki).data_id, cancel: 'true'
      assert_equal [:document], assigns(:wiki).sections_open_for(users(:blue)), "cancelling the edit should unlock wiki"
    end

    # save twice, since the behavior is different if current_user has recently saved the wiki
    (1..2).each do |i|
      str = "text %d for the wiki" % i
      put :update, id: pages(:wiki).data_id, save: true, wiki: {body: str, version: i}
      assert_equal str, assigns(:wiki).body
      assert_equal [:document], assigns(:wiki).sections_open_for(users(:blue)), "saving the edit should unlock wiki"
    end
  end

  def test_print
    login_as :orange

    get :print, id: pages(:wiki).data_id
    assert_response :success
#    assert_template 'print'
  end

end
