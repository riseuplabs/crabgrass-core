require 'test_helper'

class Group::RequestsControllerTest < ActionController::TestCase
  def setup
    @user = FactoryBot.create(:user)
    @group = FactoryBot.create(:group)
    @group.add_user! @user
    login_as @user
  end

  def test_index
    get :index, group_id: @group.to_param
    assert_response :success
  end

  def test_index_not_allowed
    stranger = FactoryBot.create(:user)
    login_as stranger
    assert_not_found do
      get :index, group_id: @group.to_param
    end
  end

  def test_create
    assert_difference 'RequestToDestroyOurGroup.count' do
      get :create, group_id: @group.to_param, type: 'destroy_group'
    end
    assert_response :redirect
  end

  def test_create_not_allowed
    stranger = FactoryBot.create(:user)
    login_as stranger
    assert_not_found do
      get :create, group_id: @group.to_param, type: 'destroy_group'
    end
  end

  def test_request_to_create_council
    group = groups(:animals)
    group.update(created_at: Time.now - 1.month)
    user = users(:blue)
    group.memberships.find_by(user.id).update(created_at: Time.now - 1.month)
    login_as user
    assert_difference 'RequestToCreateCouncil.count' do
      get :create, group_id: group.to_param, type: 'create_council'
    end
  end

  def test_request_to_create_council_not_allowed
    group = groups(:animals)
    assert_no_difference 'RequestToCreateCouncil.count' do
      get :create, group_id: group.to_param, type: 'create_council'
    end
  end

  def test_approve
    @other = FactoryBot.create(:user)
    @group.add_user! @other
    @req = RequestToCreateCouncil.create! group: @group,
                                          requestable: @group,
                                          created_by: @other

    assert_difference 'Group::Council.count' do
      post :update, group_id: @group.to_param, id: @req.id, mark: :approve
    end
    assert_response :success
  end
end
