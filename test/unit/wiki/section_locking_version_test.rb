require 'test_helper'

#
# a test for the interaction of versioning and locking and sections
#

class Wiki::LockingVersionTest < ActiveSupport::TestCase
  fixtures :users, :wikis, 'wiki/versions', 'wiki/locks'

  def setup
    @user1 = users(:blue)
    @user2 = users(:red)
    @wiki = wikis(:multi_section)
  end

  def test_normal_section_save
    @wiki.lock! 'section-one', @user1
    @wiki.lock! 'section-two', @user2
    version = @wiki.version
    @wiki.update_section!('section-one', @user1, version, "h2. section one\n\n111111111")
    @wiki.update_section!('section-two', @user2, version, "h2. section two\n\n222222222")
    assert_equal @user2, @wiki.user
    assert_equal version+2, @wiki.versions(true).size
    assert_match /h2\. section one\n\n111111111\n\nh2\. section two\n\n222222222/, @wiki.body, 'should save both sections'
  end

  def test_version_does_not_increment_for_repeat_section_save
    version = @wiki.version
    @wiki.lock! 'section-one', @user1
    @wiki.update_section!('section-one', @user1, version, "h2. section one\n\n111111111")
    @wiki.lock! 'section-two', @user1
    @wiki.update_section!('section-two', @user1, version+1, "h2. section two\n\n222222222")
    assert_equal version+1, @wiki.versions(true).size, 'version should increment by 1'
  end

  def test_two_users_repeat_save
    version = @wiki.version
    @wiki.lock! 'section-two', @user2

    @wiki.lock! 'section-one', @user1
    @wiki.update_section!('section-one', @user1, version, "h2. section one\n\n111111111")

    @wiki.lock! 'section-one', @user1
    @wiki.update_section!('section-one', @user1, version, "h2. section one\n\none one one")

    @wiki.update_section!('section-two', @user2, version, "h2. section two\n\n222222222")

    assert_match /h2\. section one\n\none one one\n\nh2\. section two\n\n222222222/, @wiki.body, 'should save all changes'
  end

end

