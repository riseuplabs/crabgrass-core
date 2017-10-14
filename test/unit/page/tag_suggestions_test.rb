require 'test_helper'

class Page::TagSuggestionsTest < ActiveSupport::TestCase

  fixtures :all

  def test_user_tag
    create_user_page tag_list: "user tag"
    user_page = create_user_page
    tags = suggest_tags(user_page, users(:blue))
    assert tags.include? "user tag"
  end

  def test_group_member_tag
    create_group_page tag_list: "shared group tag"
    tags = suggest_tags(create_group_page, users(:blue))
    assert tags.include? "shared group tag"
  end

  def test_non_group_member_secret_tag
    group_page = create_group_page tag_list: "secret group tag"
    tags = suggest_tags(create_user_page, users(:dolphin))
    assert_not tags.include? "secret group tag"
  end

  def test_non_group_member_shared_tag
    group_page = create_group_page tag_list: "group tag shared with dolphin"
    group_page.add(users(:dolphin), access: :edit)
    group_page.save!
    tags = suggest_tags(create_user_page, users(:dolphin))
    assert tags.include? "group tag shared with dolphin"
  end

  def test_user_recent_tags
    old_tags = %w[one two three four five six seven]
    new_tags = %w[eight nine ten eleven twelve thirteen]
    create_user_page tag_list: old_tags
    create_user_page tag_list: new_tags
    recent_tags = suggest_recent_tags(create_user_page, users(:blue))
    assert_equal new_tags.sort, recent_tags
  end

  def test_user_popular_tags
    common_tags = %w[apple cherry grape orange banana strawberry]
    rare_tags = %w[bug error fault mistake crash debug]
    3.times {create_user_page tag_list: common_tags}
    create_user_page tag_list: rare_tags
    popular_tags = suggest_popular_tags(create_user_page, users(:blue))
    assert_equal common_tags.sort, popular_tags
  end

  protected

  def suggest_tags page, user
    suggestions = Page::TagSuggestions.new(page, user)
    suggestions.all.map(&:name).sort
  end

  def suggest_recent_tags page, user
    suggestions = Page::TagSuggestions.new(page, user)
    suggestions.recent.map(&:name).sort
  end

  def suggest_popular_tags page, user
    suggestions = Page::TagSuggestions.new(page, user)
    suggestions.popular.map(&:name).sort
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
