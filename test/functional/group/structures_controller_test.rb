require_relative '../../test_helper'

class Group::StructuresControllerTest < ActionController::TestCase
  fixtures :all

  def setup
    @user  = FactoryGirl.create(:user)
    @group  = FactoryGirl.create(:group)
    @group.add_user! @user
  end


  def test_new_committee
    login_as @user
    assert_permission :may_edit_group_structure? do
      get :new,
        group_id: @group.to_param,
        type: 'committee'
    end
    assert_response :success
  end

  def test_create_committee
    login_as @user
    assert_permission :may_edit_group_structure? do
      assert_difference '@group.committees.count' do
        get :create,
          group_id: @group.to_param,
          type: 'committee',
          group: committee_attributes
      end
    end
    assert_response :redirect
  end

  # two committees of different groups can have the same name.
  def test_create_committee_namespace
    login_as @user
    assert_permission :may_edit_group_structure? do
      assert_difference '@group.committees.count' do
        get :create,
          group_id: @group.to_param,
          type: 'committee',
          group: committee_attributes(name: 'the-warm-colors')
      end
    end
    assert_response :redirect
  end

  # the same group can have only one committee with the same name.
  def test_create_no_duplicates
    login_as users(:blue)
    assert_permission :may_edit_group_structure? do
      assert_no_difference 'Committee.count' do
        get :create,
          group_id: groups(:rainbow),
          type: 'committee',
          group: committee_attributes(name: 'the-warm-colors')
      end
    end
  end

  def test_new_council
    login_as @user
    assert_permission :may_edit_group_structure? do
      get :new,
        group_id: @group.to_param,
        type: 'council'
    end
    assert_response :success
  end

  def test_create_council
    login_as @user
    assert_permission :may_edit_group_structure? do
      assert_difference '@group.committees.count' do
        get :create,
          group_id: @group.to_param,
          type: 'council',
          group: committee_attributes
      end
    end
    assert_response :redirect
  end

  def committee_attributes(attrs = {})
    FactoryGirl.attributes_for(:committee).merge(attrs)
  end

end
