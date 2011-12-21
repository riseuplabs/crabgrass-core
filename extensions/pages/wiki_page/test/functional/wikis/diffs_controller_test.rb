require File.dirname(__FILE__) + '/../../../../../../test/test_helper'

class Wikis::DiffsControllerTest < ActionController::TestCase
  fixtures :pages, :users, :user_participations, :wikis, :groups

  def test_diff
    login_as :orange

    (1..5).zip([:orange, :yellow, :blue, :red, :purple]).each do |i, user|
      pages(:wiki).data.update_document!(users(user), i, "text %d for the wiki" % i)
    end

    post :diff, :wiki_id => pages(:wiki).data_id, :id => "4-5"
    assert_response :success

    assert_equal assigns(:wiki).versions.reload.find_by_version(4).body_html, assigns(:old_markup)
    assert_equal assigns(:wiki).versions.reload.find_by_version(5).body_html, assigns(:new_markup)
    assert assigns(:difftext).length > 10, "difftext should contain something substantial"
  end

end
