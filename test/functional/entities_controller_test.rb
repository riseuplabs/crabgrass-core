require 'test_helper'

class EntitiesControllerTest < ActionController::TestCase
  def test_preloading_entities
    login_as :blue
    blue = users(:blue)
    get :index, params: {format: :json, query: "", view: :all}, xhr: true
    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    friends_and_peers = (blue.friends + blue.peers).uniq
    total_count = friends_and_peers.count + blue.all_groups.count
    assert_equal total_count, assigns(:entities).count
    assert_equal total_count, response['suggestions'].size,
                 'suggestions should contain all friends, peers and groups.'
    assert_holds_entities(response, '', 5)
  end

  def test_querying_entities
    login_as :red
    get :index, params: {format: :json, query: "pu", view: :all}, xhr: true
    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert_holds_entities(response, 'pu')
  end

  def test_querying_entities_without_groups
    # Regression test.
    # The sql term for querying was messed up for users who
    # did not have any groups.
    login_as :quentin
    assert_equal 0, users(:quentin).groups.count,
                 'quentin should not be in any groups.'
    get :index, params: {format: :json, query: "an", view: :all}, xhr: true
    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert_holds_entities(response, 'an')
  end

  def test_querying_entities_without_friends
    # Regression test.
    # The sql term for querying was messed up for users who
    # did not have any friends.
    login_as :red
    assert_equal 0, users(:red).friends.count,
                 'red should not have any friends.'
    get :index, params: {format: :json, query: "qu", view: :all}, xhr: true
    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert_holds_entities(response, 'qu')
  end

  def test_entities_respect_group_privacy
    login_as :red
    assert !users(:red).member_of?(groups(:private_group)),
           'red should not be in the private group.'
    get :index, params: {format: :json, query: "pri", view: :all}, xhr: true
    assert_no_suggestions "red can't see any group starting with 'pri'"
  end

  def test_entities_respect_user_privacy
    login_as :gerrard
    users(:red).revoke_access! public: :view
    get :index, params: {format: :json, query: "re", view: :all}, xhr: true
    assert_no_suggestions "gerrard can't see red after it removed public access"
  end

  def test_people_respect_user_privacy
    login_as :gerrard
    users(:red).revoke_access! public: :view
    get :index, params: {format: :json, query: "re", view: :users}, xhr: true
    assert_no_suggestions "gerrard can't see red after it removed public access"
  end

  def test_recipients_respect_user_privacy
    login_as :gerrard
    users(:red).revoke_access! public: :view
    get :index, params: {format: :json, query: "re", view: :recipients}, xhr: true
    assert_no_suggestions "gerrard can't see red after it removed public access"
  end

  def assert_holds_entities(response, query = nil, min_results = 0)
    assert_equal response['suggestions'].size, response['data'].size,
                 'there should be as many data objects as suggestions.'
    assert response['suggestions'].size > min_results,
           "There should be results for the query '#{query}'."
    return unless query
    assert_equal response['query'], query,
                 'response.query should contain the query string.'
  end

  protected

  def assert_no_suggestions(message = 'did not expect autocomplete suggestions')
    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal [], response['suggestions'], message
  end
end
