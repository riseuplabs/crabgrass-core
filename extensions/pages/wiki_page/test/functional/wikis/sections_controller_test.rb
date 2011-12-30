require File.dirname(__FILE__) + '/../../../../../../test/test_helper'

class Wikis::SectionsControllerTest < ActionController::TestCase
  fixtures :pages, :users, :user_participations, :wikis

  def test_edit
    login_as :blue
    xhr :get, :edit, :wiki_id => pages(:multi_section_wiki).data_id, :id => "second-oversection"

    assert_response :success

    wiki = assigns(:wiki)
    blue = users(:blue)

    assert_equal blue, wiki.locker_of("second-oversection"), "wiki second oversection should be locked by blue"

    # nothing should appear locked to blue
    assert_equal wiki.all_sections, wiki.sections_open_for(users(:blue)), "no sections should look locked to blue"
    assert_equal wiki.all_sections - ['section-three', 'second-oversection', :document],
                  wiki.sections_open_for(users(:gerrard)),
                  "no sections except what blue has locked (and its ancestors) should look locked to gerrard"

  end

  # various regression tests for text that has thrown errors in the past.
  def test_edit_with_problematic_text
    login_as :blue

    ##
    ## headings without a leading return. (ie "</ul><h1>" )
    ##

    page = WikiPage.create! :title => 'problem text', :owner => 'blue' do |page|
      page.data = Wiki.new(:body => "\n\nh1. hello\n\n** what?\n\nh1. goodbye\n\n")
    end
    get :show, :wiki_id => page.data_id
    page = assigns(:page)
    assert_nothing_raised do
      xhr :get, :edit, :wiki_id => page.data_id, :id => "hello"
    end

    assert_response :success
  end

  def test_update
    starting_all_sections = pages(:multi_section_wiki).wiki.all_sections
    login_as :blue
    # save the new (without a header)
    xhr :put, :update,
      :wiki_id => pages(:multi_section_wiki).data_id,
      :id => "section-three",
      :wiki => {:body => "a line"}

    assert_response :success
    wiki = assigns(:wiki)
    wiki.reload

    assert_equal starting_all_sections - ['section-three'], wiki.all_sections, "section three should have been deleted"
    expected_body = pages(:multi_section_wiki).wiki.body.dup

    expected_body.gsub!("h2. section three\n\ns3 text first line\ns3 last lime", "a line")
    assert_equal expected_body, wiki.body, "wiki body should be updated"

  end


end
