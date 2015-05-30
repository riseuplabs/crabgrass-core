require 'integration_test'

class GroupCreationTest < IntegrationTest

  def setup
    super
    @user = users(:blue)
    login
  end

  def test_create_group
    create_group :group
    assert_group_created
  end

  def test_create_network
    create_group :network, member: 'animals'
    assert_group_created
  end

  def test_create_committee
    create_group :committee, parent: 'animals'
    assert_group_created
  end

  def test_create_council
    create_group :council, parent: 'animals'
    assert_group_created
  end

  def create_group(type, attrs = {})
    parent = attrs.delete :parent
    member = attrs.delete :member
    @group = FactoryGirl.build type, attrs
    type = :organization if type == :group
    click_on 'Groups'
    click_on 'Create Group'
    click_on type.to_s.pluralize.capitalize
    click_on parent if parent.present?
    fill_in 'Name', with: @group.name
    fill_in 'Display Name', with: @group.full_name
    select member, from: 'Group' if member
    click_on 'Create'
  end

  def assert_group_created
    assert_content 'Group was successfully created'
    assert_content @group.display_name
    assert_equal '/' + @group.name, current_path
  end

end


