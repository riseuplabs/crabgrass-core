require 'test_helper'

class Group::StructuresControllerTest < ActionController::TestCase
  def setup
    @user = FactoryBot.create(:user)
    @group = FactoryBot.create(:group)
    @group.add_user! @user
  end

  def test_new_committee
    login_as @user
    get :new, params: { group_id: @group.to_param, type: 'committee' }
    assert_response :success
  end

  def test_create_committee
    login_as @user
    assert_difference '@group.committees.count' do
      get :create, params: { group_id: @group.to_param, type: 'committee', group: committee_attributes }
    end
    assert_response :redirect
  end

  def test_create_committee_not_allowed
    stranger = FactoryBot.create(:user)
    login_as stranger
    assert_not_found do
      get :create, params: { group_id: @group.to_param, type: 'committee', group: committee_attributes }
    end
  end

  def test_create_committee_namespace
    login_as @user
    assert_difference '@group.committees.count' do
      get :create, params: { group_id: @group.to_param, type: 'committee', group: committee_attributes(name: 'the-warm-colors') }
    end
    assert_response :redirect
  end

  def test_create_no_duplicates
    login_as users(:blue)
    assert_no_difference 'Group::Committee.count' do
      get :create, params: { group_id: groups(:rainbow), type: 'committee', group: committee_attributes(name: 'the-warm-colors') }
    end
  end

  def test_new_council
    login_as @user
    get :new, params: { group_id: @group.to_param, type: 'council' }
    assert_response :success
  end

  def test_create_council
    login_as @user
    assert_difference '@group.committees.count' do
      get :create, params: { group_id: @group.to_param, type: 'council', group: committee_attributes }
    end
    assert_response :redirect
  end

  def test_create_council_not_allowed
    stranger = FactoryBot.create(:user)
    login_as stranger
    assert_not_found do
      get :create, params: { group_id: @group.to_param, type: 'council', group: committee_attributes }
    end
  end

  def committee_attributes(attrs = {})
    FactoryBot.attributes_for(:committee).merge(attrs)
  end
end
