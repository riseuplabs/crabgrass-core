require 'integration_test'

class GroupCreationTest < IntegrationTest

  def setup
    super
    @user = users(:blue)
    login
  end

  def test_create_group
    visit_new_group_form
    create_group :group, name: 'new_organization'
    assert_group_created
  end

  def test_create_network
    visit_new_group_form :network
    create_group :network, member: 'animals'
    assert_group_created
  end

  def test_create_committee
    visit_new_group_form :committee
    click_link groups(:cnt).name
    create_group :committee, name: 'new_committee', parent: groups(:cnt)
    assert_group_created
  end

  def test_create_council
    visit_new_group_form
    create_parent_group :group, name: 'parent_group'
    visit_new_group_form :council
    click_link @parent_group.name
    create_group :council, name: 'new_council', parent: @parent_group
    assert_group_created
  end

  protected

  def visit_new_group_form(type = :group)
    type = :organization if type == :group
    click_on 'Groups'
    click_on 'Create Group'
    click_on type.to_s.pluralize.capitalize
  end

  def create_group(type = :group, attrs = {})
    member = attrs.delete :member
    @group = FactoryGirl.build type, attrs
    fill_in 'Name', with: @group.name
    fill_in 'Display Name', with: @group.display_name
    # include parent in name
    @group.clean_names
    select member, from: 'Group' if member
    select 'English', from: 'Language'
    click_on 'Create'
  end

  def create_parent_group(type = :group, attrs = {})
    @parent_group = FactoryGirl.build type, attrs
    fill_in 'Name', with: @parent_group.name
    fill_in 'Display Name', with: @parent_group.display_name
    click_on 'Create'
  end

  def assert_group_created
    assert_content 'Group was successfully created'
    assert_content @group.display_name
    assert_equal "/#{@group.name}", current_path
  end
end
