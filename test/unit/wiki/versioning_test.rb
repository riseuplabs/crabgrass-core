require_relative '../test_helper'

class Wiki::VersioningTest < ActiveSupport::TestCase
  fixtures :users, :wikis
  include WikiTestHelper

  def setup
    @wiki = Wiki.new
    @user = users(:blue)
    @different_user = users(:red)
  end

  def test_new_wikis_have_no_versions
    assert @wiki.versions.empty?
  end

  def test_save_versions
    #
    # save first version
    #
    assert_difference '@wiki.versions.size' do
      @wiki.update_attributes!(body: 'hi', user: @user)
    end
    assert_latest_body @wiki, 'hi'
    assert_latest_body_html @wiki, '<p>hi</p>'
    assert_latest_raw_structure @wiki, wiki_raw_structure_for_n_byte_body(2)
    assert_no_difference '@wiki.versions.size', 'saving the same body should never produce a new version' do
      @wiki.update_attributes!(body: 'hi', user: @different_user)
    end

    #
    # save second version
    #
    assert_difference '@wiki.versions.size' do
      @wiki.update_attributes!(body: 'hi there', user: @user)
    end

    #
    # save third version
    #
    @wiki.body = 'hey you'
    @wiki.user = @user
    assert_no_difference '@wiki.versions.size' do
      assert_nothing_raised { @wiki.save! }
    end
    assert_latest_body @wiki, 'hey you'
    assert_latest_body_html @wiki, '<p>hey you</p>'
    assert_latest_raw_structure @wiki, wiki_raw_structure_for_n_byte_body(7)
  end

  def test_initial_empty_body
    assert_no_new_versions_on_empty_body('')
  end

  def test_initial_nil_body
    assert_no_new_versions_on_empty_body(nil)
  end

  #
  # save with 'oi', '' (blank body) and 'vey' bodies by alternating users
  #
  def test_save_empty_body
    assert_difference '@wiki.versions.size', 2 do
      @wiki.update_attributes!(body: 'oi', user: @user)
      @wiki.update_attributes!(body: '', user: @different_user)
      @wiki.update_attributes!(body: 'vey', user: @user)
    end

    assert_equal ['oi', 'vey'], @wiki.versions.collect(&:body),
      "should have only 'oi' and 'vey' versions"

    assert_equal [@user, @user], @wiki.versions.collect(&:user),
       "should have the right user for its versions"
  end

  def test_soft_revert
    @wiki = Wiki.create! body: '1111', user: @user
    @wiki.update_attributes!(body: '2222', user: @different_user)
    @wiki.update_attributes!(body: '3333', user: @user)
    @wiki.update_attributes!(body: '4444', user: @different_user)

    @wiki.revert_to_version(@wiki.find_version(3), users(:purple))
    assert_equal '3333', @wiki.versions.find_by_version(5).body,
      "should create a new version equal to the older version"
    assert_equal '3333', @wiki.body,
      "should revert wiki body"
  end

  def test_hard_revert
    @wiki = Wiki.create! body: '1111', user: @user
    @wiki.update_attributes!(body: '2222', user: @different_user)
    @wiki.update_attributes!(body: '3333', user: @user)
    @wiki.update_attributes!(body: '4444', user: @different_user)

    @wiki.revert_to_version!(2, users(:purple))
    assert_equal '2222', @wiki.body,  "should revert wiki body"
    assert_equal 2, @wiki.versions(true).size, "should delete all newer versions"
    assert_equal '2222', @wiki.versions.find_by_version(2).body, "should keep version 2"
  end

  private

  def assert_no_new_versions_on_empty_body(initial_body)
    @wiki = Wiki.new
    @wiki.update_attributes!(body: initial_body, user: @user)

    assert_latest_body @wiki, initial_body
    assert_latest_body_html @wiki, ''
    assert_latest_raw_structure @wiki, wiki_raw_structure_for_n_byte_body(0)

    #
    # save from different user
    #
    assert_no_difference '@wiki.versions.size' do
      @wiki.update_attributes!(body: 'oi', user: @different_user)
    end
    assert_latest_body @wiki, 'oi'

    #
    # save from same user
    #
    @wiki = Wiki.new
    @wiki.update_attributes!(body: initial_body, user: @user)
    assert_no_difference '@wiki.versions.size' do
      @wiki.update_attributes!(body: 'oi', user: @user)
    end
    assert_latest_body @wiki, 'oi'
  end

end
