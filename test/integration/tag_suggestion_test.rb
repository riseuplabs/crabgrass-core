# encoding: utf-8

require 'javascript_integration_test'

class TagSuggestionTest < JavascriptIntegrationTest

  fixtures :all

  def test_tag_from_user_suggestion
    create_user_page tag_list: %w[summer winter],
      created_by: users(:dolphin)
    tag_me = create_user_page created_by: users(:dolphin)
    login users(:dolphin)
    visit '/dolphin/' + tag_me.name_url
    tag_page_from_suggestion 'summer'
    assert_page_tags 'summer'
  end

  def test_tag_from_group_suggestion_as_non_member
    group_page = create_group_page tag_list: ['rainbowsecret']
    tag_me = create_group_page tag_list: ['nosecret']
    tag_me.add(users(:dolphin), access: :edit)
    tag_me.save!
    login users(:dolphin)
    visit '/rainbow/' + tag_me.name_url
    assert_page_tags 'nosecret'
    assert_no_content 'rainbowsecret'
  end

  def test_tag_from_group_suggestion_as_member
    group_page = create_group_page tag_list: ['rainbowsecret']
    tag_me = create_group_page
    login users(:red)
    visit '/rainbow/' + tag_me.name_url
    tag_page_from_suggestion 'rainbowsecret'
    assert_page_tags 'rainbowsecret'
    assert tag_me.tags.map(&:name).include? 'rainbowsecret'
  end

  def test_tag_suggested_from_group_participation
    tag_source_page = create_user_page tag_list: ['sharedtag', 'ourtag']
    tag_source_page.add(users(:dolphin))
    tag_source_page.add(groups(:rainbow))
    tag_source_page.save!
    tag_me = FactoryGirl.create :page, created_by: users(:blue)
    tag_me.add(groups(:rainbow))
    tag_me.add(users(:dolphin), access: :admin)
    tag_me.save!
    login users(:dolphin)
    visit '/rainbow/' + tag_me.name_url
    tag_page_from_suggestion 'sharedtag'
    click_on 'Close', match: :first
    tag_page_from_suggestion 'ourtag'
    assert_page_tags ['sharedtag', 'ourtag']
    assert tag_me.tags.map(&:name).include? 'sharedtag'
  end

  def create_group_page(options = {})
    attrs = options.reverse_merge created_by: users(:blue),
      owner: groups(:rainbow)
    FactoryGirl.create :page, attrs
  end

  def create_user_page(options = {})
    attrs = options.reverse_merge created_by: users(:blue)
    FactoryGirl.create :page, attrs
  end
end
