require File.dirname(__FILE__) + '/../../../../../../test/test_helper'

class Wikis::VersionsControllerTest < ActionController::TestCase
  fixtures :pages, :users, :user_participations, :wikis, :groups

  def setup
    Crabgrass::Wiki::HTMLDiff.log_to_stdout = false # set to true for debugging
  end

  def test_version_show
    login_as :orange
    pages(:wiki).add groups(:rainbow), :access => :edit
    wiki = pages(:wiki).data

    # create versions
    (1..5).zip([:orange, :yellow, :blue, :red, :purple]).each do |i, user|
      login_as user
      wiki.update_section!(:document, users(user), i, "text %d for the wiki" % i)
    end

    wiki.update_section!(:document, users(:purple), 6, "text 6 for the wiki")

    login_as :orange
    wiki.versions.reload

    # find versions
    get :show, :wiki_id => wiki.id, :id => 6
    assert_response :success
    assert_equal 6, assigns(:version).version
    assert_equal 'text 6 for the wiki', assigns(:wiki).body
  end

  def test_show_invalid_version
    pages(:wiki).add groups(:rainbow), :access => :edit
    wiki = pages(:wiki).data
    wiki.update_section!(:document, users(:purple), 1, "text for the wiki")
    login_as :orange
    # should fail gracefully for non-existant version
    get :show, :wiki_id => wiki.id, :id => 7
    assert_response 404
  end

  def test_revert
    login_as :orange
    page = pages(:wiki)
    wiki = page.data
    wiki.update_section!(:document, users(:blue), 1, "version 1")
    wiki.update_section!(:document, users(:yellow), 2, "version 2")
    post :revert, :wiki_id => wiki.id, :id => 1

    wiki.reload

    assert_redirected_to wiki_versions_path(wiki),
      "revert should redirect to wiki versions list"
    assert_equal "version 1", wiki.body
  end

end
