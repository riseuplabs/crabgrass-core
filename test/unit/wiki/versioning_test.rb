require 'test_helper'

class Wiki::VersioningTest < ActiveSupport::TestCase

  include WikiTestHelper

  def setup
    @wiki = Wiki.new
    @user = users(:blue)
    @different_user = users(:red)
  end

  def test_new_wikis_have_no_versions
    assert_empty @wiki.versions
  end

  def test_updates_combined
    assert_difference '@wiki.versions.size' do
      update_wiki
      update_wiki
    end
    assert_equal 1, @wiki.version
  end

  def test_different_users_separate_versions
    assert_difference '@wiki.versions.size', 3 do
      update_wiki
      update_wiki user: @different_user
      update_wiki
    end
    assert_equal 3, @wiki.version
  end

  def test_same_body_same_version
    assert_difference '@wiki.versions.size' do
      @wiki.update_section!(:document, @user, nil, 'hi')
      @wiki.update_section!(:document, @different_user, nil, 'hi')
    end
    assert_equal 1, @wiki.version
    assert_equal @user, @wiki.versions.last.user
  end

  def test_save_empty_body
    assert_difference '@wiki.versions.size', 2 do
      update_wiki body: 'oi'
      update_wiki body: '', user: @different_user
      update_wiki body: 'vey', user: @user
    end

    assert_equal ['oi', 'vey'], @wiki.versions.collect(&:body),
      "should have only 'oi' and 'vey' versions"

    assert_equal [@user, @user], @wiki.versions.collect(&:user),
       "should have the right user for its versions"
  end

  def test_soft_revert
    @wiki = Wiki.create! body: '1', user: @user
    update_wiki user: @different_user
    update_wiki
    update_wiki user: @different_user

    @wiki.revert_to_version(@wiki.find_version(3), users(:purple))
    assert_equal '3', @wiki.versions.find_by_version(5).body,
      "should create a new version equal to the older version"
    assert_equal '3', @wiki.body,
      "should revert wiki body"
  end

  def test_hard_revert
    @wiki = Wiki.create! body: '1', user: @user
    update_wiki user: @different_user
    update_wiki
    update_wiki user: @different_user

    @wiki.revert_to_version!(2, users(:purple))
    assert_equal '2', @wiki.body,  "should revert wiki body"
    assert_equal 2, @wiki.versions(true).size,
      "should delete all newer versions"
    assert_equal '2', @wiki.versions.find_by_version(2).body,
      "should keep version 2"
    assert_equal 2, @wiki.version
  end

  def test_initial_empty_body
    update_wiki body: ''
    assert_equal '', @wiki.body
    assert_equal '', @wiki.body_html
    assert_equal empty_raw_structure, @wiki.raw_structure
  end

  def test_initial_nil_body
    update_wiki body: nil
    assert_nil @wiki.body
    assert_equal '', @wiki.body_html
    assert_equal empty_raw_structure, @wiki.raw_structure
  end

  private

  def update_wiki(body: new_body, user: @user)
    @wiki.update_attributes! body: body, user: user
  end

  def new_body
    (@wiki.body || 'a').succ
  end

  def empty_raw_structure
    {
      name: nil,
      children: [],
      start_index: 0,
      end_index: -1,
      heading_level: 0
    }
  end

end
