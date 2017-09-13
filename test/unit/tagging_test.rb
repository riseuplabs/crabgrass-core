require 'test_helper'

class TaggingTest < ActiveSupport::TestCase
  def setup
    @obj1 = Page.new title: 'test_tags1'
    @obj1.tag_list = 'pale'
    @obj1.save

    @obj2 = Page.new title: 'test_tags2'
    @obj2.tag_list = 'pale, imperial'
    @obj2.save
  end

  def test_tag_list
    @obj2.tag_list = 'hoppy, pilsner'
    assert_equal %w[hoppy pilsner], @obj2.tag_list
  end

  def test_tagged_with
    @obj1.tag_list = 'seasonal, lager, ipa'
    @obj1.save
    @obj2.tag_list = 'lager, stout, fruity, seasonal'
    @obj2.save

    result1 = [@obj1]
    assert_equal Page.tagged_with('ipa', on: :tags), result1

    result2 = [@obj1.id, @obj2.id].sort
    assert_equal result2,
      Page.tagged_with('seasonal', on: :tags).map(&:id).sort
    assert_equal result2,
      Page.tagged_with(%w[seasonal lager], on: :tags).map(&:id).sort
  end

  def test_users_tag_cache
    user = FactoryGirl.create(:user)
    page = FactoryGirl.create(:page, title: 'hi')
    page.tag_list = 'one, two'
    page.save!

    assert !page.users.include?(user)
    assert user.tags.empty?

    page.add(user)
    page.save!
    user.reload
    assert user.tags.include?(page.tags.first), user.tags.inspect

    page.tag_list = 'aaaa,bbbb,cccc'
    page.tags_will_change! # for now, manual dirty tracking
    page.save!
    user.reload
    user_tags = user.tags.collect(&:name).sort
    assert_equal %w[aaaa bbbb cccc], user_tags

    page.destroy
    user.reload
    assert user.tags.empty?
  end

  def test_create_with_tags
    page = nil
    assert_nothing_raised do
      page = DiscussionPage.create! title: 'tag me!', tag_list: 'one,two,three'
    end
    assert page.tag_list.include?('one')
    page = Page.find(page.id)
    assert page.tag_list.include?('one')
  end
end
