require 'integration_test'

class GroupCreationTest < IntegrationTest

  def setup
    super
    @user = users(:blue)
    login
  end

  def test_create_group
    visit_new_group_form
    create_group
    assert_group_created
  end

  def test_create_network
    visit_new_group_form :network
    create_group :network, member: 'animals'
    assert_group_created
  end

  def test_create_committee
    visit_new_committee_form :animals
    create_group :committee, parent: groups(:animals), name: 'cold'
    assert_group_created
  end

  def test_create_council
    visit_new_group_form
    create_group
    visit_new_committee_form @group.name, council: true
    create_group :council, parent: @group
    assert_group_created
  end

  def visit_new_group_form(type = :group)
    type = :organization if type == :group
    click_on 'Groups'
    click_on 'Create Group'
    click_on type.to_s.pluralize.capitalize
  end

  def visit_new_committee_form(group, options = {})
    visit "/groups/#{group}/structure"
    type = options[:council] ? 'Council' : 'Committee'
    click_link "Create a new #{type}"
  end

  def create_group(type = :group, attrs = {})
    member = attrs.delete :member
    @group = FactoryGirl.build type, attrs
    fill_in 'Name', with: @group.name
    fill_in 'Display Name', with: @group.display_name
    # include parent in name
    @group.clean_names
    select member, from: 'Group' if member
    click_on 'Create'
  end

  def assert_group_created
    assert_content 'Group was successfully created'
    assert_content @group.display_name
    assert_equal "/#{@group.name}", current_path
  end

end


