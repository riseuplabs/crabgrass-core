require File.dirname(__FILE__) + '/../../../../../../test/test_helper'

class Wikis::WikisControllerTest < ActionController::TestCase
  fixtures :pages, :users, :user_participations, :wikis

  def test_edit
    login_as :orange
    pages(:wiki).add users(:orange), :access => :edit
    pages(:wiki).add users(:blue), :access => :edit

    get :edit, :page_id => pages(:wiki).id
    assert_equal [], assigns(:wiki).sections_open_for(users(:blue)), "editing a wiki should lock it"

    assert_equal users(:orange), assigns(:wiki).locker_of(:document), "should be locked by orange"

    assert_no_difference 'pages(:wiki).updated_at' do
      put :update, :page_id => pages(:wiki).id, :cancel => 'true'
      assert_equal [:document], assigns(:wiki).sections_open_for(users(:blue)), "cancelling the edit should unlock wiki"
    end

    # save twice, since the behavior is different if current_user has recently saved the wiki
    (1..2).each do |i|
      str = "text %d for the wiki" % i
      put :update, :page_id => pages(:wiki).id, :save => true, :wiki => {:body => str, :version => i}
      assert_equal str, assigns(:wiki).body
      assert_equal [:document], assigns(:wiki).sections_open_for(users(:blue)), "saving the edit should unlock wiki"
    end
  end

  def test_break_lock
    login_as :blue

    page = pages(:wiki)
    wiki = page.data

    user = users(:blue)
    different_user = users(:orange)

    page.add(user, :access => :admin)
    page.add(different_user, :access => :admin)

    wiki.lock!(:document, different_user)

    assert_equal [], wiki.sections_open_for(user)

    put :update, :page_id => pages(:wiki).id, :break_lock => true

    assert_equal [:document], wiki.reload.sections_open_for(user)
    assert_response :success
    assert_equal wiki.body, assigns(:wiki).body
    assert_rendered_full_page_edit_form(wiki.body)
  end

  protected

  def assert_rendered_full_page_edit_form(body)
    assert_select '#tab-edit-greencloth' do
      assert_select 'textarea', :text => body
    end

    assert_select ".wiki_buttons" do
      assert_select 'input' do
        assert_select '[name=save]'
      end
    end
  end


end
