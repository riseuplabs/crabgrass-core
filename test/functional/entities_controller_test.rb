require File.dirname(__FILE__) + '/../test_helper'

class EntitiesControllerTest < ActionController::TestCase
  fixtures :users, :groups, :keys,
          :memberships, :user_participations, :group_participations,
          :pages, :relationships, :geo_countries, :geo_admin_codes, :geo_places

  def test_preloading_entities
    login_as :blue
    blue = users(:blue)
    xhr :get, :index, :format => :json, :view => :all, :query => ''
    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    friends_and_peers = (blue.friends + blue.peers).uniq
    assert_equal response["suggestions"].size,
      friends_and_peers.count + blue.all_groups.count,
      "suggestions should contain all friends, peers and groups."
    assert_equal response["suggestions"].size, response["data"].size,
      "there should be as many data objects as suggestions."
    assert response["suggestions"].size > 5,
      "there should be a number of preloaded suggestions for blue."
    assert_equal response["query"], '',
      "query should be empty for preloading."
  end

  def test_querying_entities
    login_as :red
    xhr :get, :index, :format => :json, :view => :all, :query => 'pu'
    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal response["suggestions"].size, response["data"].size,
      "there should be as many data objects as suggestions."
    assert response["suggestions"].size > 0,
      "there should be suggestions for red starting with 'pu'."
    assert_equal response["query"], 'pu',
      "response.query should contain the query string."
  end

  def test_querying_entities_without_groups
    # Regression test.
    # The sql term for querying was messed up for users who
    # did not have any groups.
    login_as :quentin
    assert_equal 0, users(:quentin).groups.count,
      "quentin should not be in any groups."
    xhr :get, :index, :format => :json, :view => :all, :query => 'an'
    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal response["suggestions"].size, response["data"].size,
      "there should be as many data objects as suggestions."
    assert response["suggestions"].size > 0,
      "there should be suggestions for quentin starting with 'an' -> animals."
    assert_equal response["query"], 'an',
      "response.query should contain the query string."
  end

  def test_querying_entities_without_friends
    # Regression test.
    # The sql term for querying was messed up for users who
    # did not have any friends.
    login_as :red
    assert_equal 0, users(:red).friends.count,
      "red should not have any friends."
    xhr :get, :index, :format => :json, :view => :all, :query => 'qu'
    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal response["suggestions"].size, response["data"].size,
      "there should be as many data objects as suggestions."
    assert response["suggestions"].size > 0,
      "there should be suggestions for red starting with 'qu' -> quentin."
    assert_equal response["query"], 'qu',
      "response.query should contain the query string."
  end

  def test_entities_respect_group_privacy
    login_as :red
    assert !users(:red).member_of?(groups(:private_group)),
      "red should not be in the private group."
    xhr :get, :index, :format => :json, :view => :all, :query => 'pri'
    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal [], response["suggestions"],
      "red can't see any group starting with 'pri'"
  end

  def test_entities_respect_user_privacy
    login_as :green
    assert_equal ["blue"], users(:orange).friends.map(&:login)
      "orange should only have blue as a friend."
    xhr :get, :index, :format => :json, :view => :all, :query => 're'
    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal [], response["suggestions"],
      "orange can't see red"
  end

  def test_people_respect_user_privacy
    login_as :green
    assert_equal ["blue"], users(:orange).friends.map(&:login)
      "orange should only have blue as a friend."
    xhr :get, :index, :format => :json, :view => :users, :query => 're'
    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal [], response["suggestions"],
      "orange can't see red"
  end

#  def test_querying_locations
#    login_as :blue
#    xhr :get, :locations, :country => 1, :query => 'yen'
#    assert_response :success
#    response = ActiveSupport::JSON.decode(@response.body)
#    assert response["suggestions"].size > 0
#  end

end
