require File.dirname(__FILE__) + '/../test_helper'

class Wikis::VersionsControllerTest < ActionController::TestCase

  def setup
    @user = User.make
    @user.stubs(:member_of?).returns(true)
    @user.stubs(:may?).returns(true)
    @version = stub :version => 2,
      :user => @user,
      :updated_at => Time.now - 200.minutes,
      :previous => stub,
      :next => stub,
      :diff_id => '1-2',
      :body_html => 'stub body'
    @group = stub :class => Group
    @wiki = stub :group => @group,
      :class => Wiki,
      :pages => []
    Wiki.stubs(:find).with('3').returns(@wiki)
    login_as @user
  end

  def test_fetching_version
    @wiki.expects(:find_version).with('2').returns(@version)
    run_before_filters :show, :wiki_id => '3', :id => '2'
    assert_equal @wiki, assigned(:wiki)
    assert_equal @version, assigned(:version)
  end

  def test_version_not_found
    @wiki.expects(:find_version).with('2').
      raises Wiki::VersionNotFoundException.new(err_string = "no version 2")
    run_before_filters :show, :wiki_id => '3', :id => '2'
    assert_nil assigned(:version)
    assert_equal err_string, flashed[:error]
  end

  def test_show
    @wiki.expects(:find_version).with('2').returns(@version)
    assert_permission :may_show_wiki_version? do
      get :show, :wiki_id => '3', :id => '2'
    end
    assert_equal @version, assigns['version']
  end

  def test_index
    @wiki.expects(:versions).returns([@version])
    assert_permission :may_list_wiki_versions? do
      get :index, :wiki_id => '3'
    end
  end

  def test_destroy
    @version.expects(:destroy)
    @wiki.expects(:find_version).with('2').returns(@version)
    assert_permission :may_destroy_wiki_version? do
      delete :destroy, :wiki_id => '3', :id => '2'
    end
    assert_response :redirect
    assert_redirected_to url_for([@group, @wiki])
  end

  def test_revert
    login_as @user
    @wiki.expects(:find_version).with('2').returns(@version)
    @wiki.expects(:revert_to).with(@version, @user).returns(@version)
    assert_permission :may_revert_wiki_version? do
      post :revert, :wiki_id => '3', :id => '2'
    end
    assert_response :redirect
    assert_redirected_to url_for([@group, @wiki])
  end

end
