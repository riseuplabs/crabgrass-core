# encoding: utf-8

require 'javascript_integration_test'

class TagSuggestionTest < JavascriptIntegrationTest

  fixtures :users, :groups, 'group/memberships', :pages

  def setup
    super
    @user = users(:blue)
    login
  end

  def test_tag_from_user_suggestion
    create_page title: "Page with many tags"
    tags = %w[tag suggestions consist of six recent and popular tags like summer]
    tag_page tags
    create_page title: "Page with popular tag"
    tag_page %w[summer]
    create_page title: "Tag for tag suggestions"
    tag_page_from_suggestion 'summer'
    assert_page_tags 'summer'
  end

  def test_tag_from_group_suggestion_as_non_member
    group_page = create_group_page tag_list: ['rainbowsecret']
    group_page.save!
    @page = create_group_page tag_list: ['nosecret']
    @page.add(users(:dolphin), access: :edit)
    @page.save!
    logout
    @user = users(:dolphin)
    own_page
    login
    visit '/rainbow/' + @page.name_url
    assert_page_tags 'nosecret'
    assert_no_content 'rainbowsecret'
  end

  def test_tag_from_group_suggestion_as_member
    group_page = create_group_page tag_list: ['rainbowsecret']
    group_page.save!
    @page = create_group_page
    @page.add(users(:red), access: :admin)
    @page.save!
    logout
    @user = users(:red)
    own_page
    login
    visit '/rainbow/' + @page.name_url
    tag_page_from_suggestion 'rainbowsecret'
    assert_page_tags 'rainbowsecret'
    @page.tags(true)
    assert @page.tags.map(&:name).include? 'rainbowsecret'
  end

  def test_tag_suggested_from_group_participation
    tag_source_page = FactoryGirl.create :page, created_by: users(:blue)
    tag_source_page.tag_list = ['sharedtag', 'ourtag']
    tag_source_page.add(users(:dolphin))
    tag_source_page.add(groups(:rainbow))
    tag_source_page.save!
    @page = FactoryGirl.create :page, created_by: users(:blue)
    @page.add(groups(:rainbow))
    @page.add(users(:dolphin), access: :admin)
    @page.save!
    logout
    @user = users(:dolphin)
    own_page
    login
    visit '/rainbow/' + @page.name_url
    tag_page_from_suggestion 'sharedtag'
    click_on 'Close', match: :first
    tag_page_from_suggestion 'ourtag'
    assert_page_tags ['sharedtag', 'ourtag']
    @page.tags(true)
    assert @page.tags.map(&:name).include? 'sharedtag'
  end

  def create_group_page(options = {})
    attrs = options.reverse_merge created_by: users(:blue),
      owner: groups(:rainbow)
    FactoryGirl.create :page, attrs
  end

end
