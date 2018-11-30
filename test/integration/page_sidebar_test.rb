# encoding: utf-8

require 'integration_test'
require_relative '../helpers/integration/javascript/page_actions.rb'

class PageSidebarTest < IntegrationTest
  include PageActions
  fixtures :users, :groups, 'group/memberships', :pages

  def setup
    super
    @user = users(:blue)
    own_page
    login
    click_on own_page.title
  end

  def test_watch
    watch_page
    assert_page_watched
    unwatch_page
    assert_page_not_watched
  end

  def test_stars
    star_page
    assert_page_starred
    remove_star_from_page
    assert_page_not_starred
  end

  def test_public
    make_page_public
    assert_page_public
    make_page_private
    assert_page_private
  end
end
