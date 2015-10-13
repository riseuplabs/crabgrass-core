require_relative '../test_helper'

#
# there are some unusually written tests in the form "msg".tap{|msg| assert true, msg}
# it is done this way to make it easier to port these tests from rspec.
#

class Wiki::LockingTest < ActiveSupport::TestCase
  fixtures :users, :wikis, :wiki_versions, :wiki_locks

  def setup
    @user = users(:blue)
    @different_user = users(:red)
  end

  def test_wiki_after_locking
    @wiki = Wiki.new
    assert_difference "Wiki.count" do
      assert_difference "Wiki::Lock.count" do
        assert_nothing_raised do
          @wiki.lock!(:document, @user)
        end
      end
    end
    assert !@wiki.new_record?, "wiki should be saved"
    lock = Wiki::Lock.find_by_wiki_id(@wiki.id)
    refute_nil lock, 'lock should exist'
    lock_user = lock.locks[:document][:by]
    assert_equal @user.id, lock_user, 'lock user should be set'
  end

  def test_lock_missing_section
    # currently, locking sections that don't exist just fails silently:
    #assert_raises(Wiki::LockedError, "should raise LockedError when locking a non-existant section") do
    #  @wiki.lock! 'bad-nonexistant-section-header', @user
    #end
    #assert_raises(Wiki::LockedError, "should raise LockedError when unlocking a non-existant section") do
    #  @wiki.unlock! 'bad-nonexistant-section-header', @user
    #end
  end

  def test_double_lock
    @wiki = wikis(:multi_section)
    assert_nothing_raised do
      @wiki.lock! 'section-two', @user
    end
    assert_nothing_raised("should not raise Wiki::LockedError when locking 'section-two' section again") do
      @wiki.lock! 'section-two', @user
    end
  end

  def test_section_rename_while_locked
    @wiki = wikis(:multi_section)
    @wiki.lock! 'section-two', @user

    # now a different user goes and modifies the section titles, bypassing locks
    body = @wiki.body.sub('section two', 'section 2')
    @wiki.update_attributes!({user: @different_user, body: body, body_html: nil})

    "should be no locks".tap do |msg|
      assert @wiki.sections_locked_for(@user).empty?, msg
      assert @wiki.sections_locked_for(@different_user).empty?, msg
    end

    "should have not section locked for either user".tap do |msg|
      assert @wiki.sections_locked_for(@user).empty?, msg
      assert @wiki.sections_locked_for(@different_user).empty?, msg
    end

    "should have all sections open for either user".tap do |msg|
      assert_same_elements @wiki.all_sections, @wiki.sections_open_for(@user), msg
      assert_same_elements @wiki.all_sections, @wiki.sections_open_for(@different_user), msg
    end
  end

  def test_section_rename_in_memory
    @wiki = wikis(:multi_section)
    @wiki.lock! 'section-two', @user
    @wiki.body = @wiki.body.sub('section two', 'section 2')

    "should have no section locked for either user".tap do |msg|
      assert @wiki.sections_locked_for(@user).empty?, msg
      assert @wiki.sections_locked_for(@different_user).empty?, msg
    end

    "should have all sections open for either user".tap do |msg|
      assert_same_elements @wiki.all_sections, @wiki.sections_open_for(@user), msg
      assert_same_elements @wiki.all_sections, @wiki.sections_open_for(@different_user), msg
    end
  end

  def test_locks_appear_open_and_closed
    @wiki = wikis(:multi_section)
    @wiki.lock! 'section-two', @user

    assert_equal 'section-two', @wiki.section_edited_by(@user),
      "section-two is being edited by user"

    assert_nil @wiki.section_edited_by(@different_user),
      "should be nil from section_edited_by for a section_edited_by user"

    #
    # from @user's point of view
    #

    test_open_sections = [
      :document, 'top-oversection', 'section-two',
      'subsection-for-section-two', 'section-one', 'second-oversection'
    ]

    test_open_sections.each do |section_heading|
      "should have the #{section_heading.inspect} section open".tap do |msg|
        assert @wiki.sections_open_for(@user).include?(section_heading), msg
        assert !@wiki.sections_locked_for(@user).include?(section_heading), msg
      end
    end

    #
    # from @different_user's point of view
    #

    test_closed_sections = [
      :document, 'top-oversection', 'section-two',
      'subsection-for-section-two'
    ]

    test_closed_sections.each do |section_heading|
      "should have the #{section_heading.inspect} section closed".tap do |msg|
        assert !@wiki.sections_open_for(@different_user).include?(section_heading), msg
        assert @wiki.sections_locked_for(@different_user).include?(section_heading), msg
      end

      assert_raises(Wiki::SectionLockedError, "should raise Wiki::SectionLockedError when locking #{section_heading.inspect} section") do
        @wiki.lock! section_heading, @different_user
      end

      # current behavior is to silently ignore
      # attempts to unlock something you are not allowed to.
      #assert_raises(Wiki::SectionLockedError, "should raise Wiki::SectionLockedError when unlocking #{section_heading.inspect} section") do
      #  @wiki.release_my_lock! section_heading, @user
      #end
    end

    "should have the neighborhing sections open".tap do |msg|
      assert @wiki.sections_open_for(@different_user).include?('section-one'), msg
      assert !@wiki.sections_locked_for(@different_user).include?('section-one'), msg
      assert @wiki.sections_open_for(@different_user).include?('second-oversection'), msg
      assert !@wiki.sections_locked_for(@different_user).include?('second-oversection'), msg
    end

    #
    # release locks
    #
    test_open_sections.each do |section_heading|
      assert_nothing_raised "should raise no errors when unlocking #{section_heading.inspect} section" do
        @wiki.release_my_lock! section_heading, @user
      end
    end
  end

  def test_two_section_locks
    @wiki = wikis(:multi_section)
    @wiki.lock! 'section-two', @user
    @wiki.lock! 'section-one', @different_user

    assert @wiki.sections_open_for(@user).include?('section-two'),
      "should appear to user that 'section-two' is open"

    assert !@wiki.sections_open_for(@user).include?('section-one'),
      "should not appear to user that 'section-one' is open"

    assert @wiki.sections_open_for(@different_user).include?('section-one'),
      "should appear to the different user that 'section-one' is open"
  end

  def test_lock_then_unlock
    @wiki = wikis(:multi_section)
    @wiki.lock! 'section-two', @user
    @wiki.release_my_lock! 'section-two', @user

    "should appear the same to that user and to a different user".tap do |msg|
      assert_same_elements @wiki.sections_open_for(@user), @wiki.sections_open_for(@different_user), msg
      assert_same_elements @wiki.sections_locked_for(@user), @wiki.sections_locked_for(@different_user), msg
    end

    "should appear to a different user that all sections can be edited and none are locked".tap do |msg|
      assert_same_elements @wiki.sections_open_for(@different_user), @wiki.all_sections, msg
      assert @wiki.sections_locked_for(@different_user).empty?, msg
    end
  end

  def test_lock_document
    @wiki = wikis(:multi_section)
    @wiki.lock! :document, @user

    "should appear that this user is a locker_of document".tap do |msg|
      assert_equal @user, @wiki.locker_of(:document), msg
    end

    "should appear that this user is a locker_of a subsection".tap do |msg|
      assert_equal @user, @wiki.locker_of('section-one'), msg
    end

    "should appear to the same user that document is open for editing".tap do |msg|
      assert @wiki.section_open_for?(:document, @user), msg
    end

    "should appear to the same user that a document subsection is open for editing".tap do |msg|
      assert @wiki.section_open_for?('section-one', @user), msg
    end

    "should appear to a different user that document is locked for editing".tap do |msg|
      assert @wiki.section_locked_for?(:document, @different_user), msg
    end

    "should appear to a different user that a document subsection is locked for editing".tap do |msg|
      assert @wiki.section_locked_for?('section-one', @different_user), msg
    end

    "should appear to that user that all sections can be edited and none are locked".tap do |msg|
      assert_same_elements @wiki.sections_open_for(@user), @wiki.all_sections, msg
      assert @wiki.sections_locked_for(@user).empty?, msg
    end

    "should appear to a different user that no sections can be edited and all are locked".tap do |msg|
      assert @wiki.sections_open_for(@different_user).empty?, msg
      assert_same_elements @wiki.sections_locked_for(@different_user), @wiki.all_sections, msg
    end

    "should raise an exception (and keep the same state) when a different user tries to lock the document".tap do |msg|
      assert_raises(Wiki::SectionLockedError, msg) do
        @wiki.lock! :document, @different_user
      end

      assert_same_elements @wiki.all_sections, @wiki.sections_open_for(@user), msg
      assert @wiki.sections_open_for(@different_user).empty?, msg
      assert_same_elements @wiki.all_sections, @wiki.sections_locked_for(@different_user), msg
    end

    "should raise an exception (and keep the same state) when a different user tries to lock a section".tap do |msg|
      assert_raises(Wiki::SectionLockedError, msg) do
        @wiki.lock! 'section-one', @different_user
      end

      assert_same_elements @wiki.all_sections, @wiki.sections_open_for(@user), msg
      assert @wiki.sections_open_for(@different_user).empty?, msg
      assert_same_elements @wiki.all_sections, @wiki.sections_locked_for(@different_user), msg
    end

    "should raise a Wiki::OtherSectionLockedError if that user tries to lock another section".tap do |msg|
      assert_raises(Wiki::OtherSectionLockedError, msg) do
        @wiki.lock! 'section-one', @user
      end
    end
  end

  def test_lock_then_unlock_whole_document
    @wiki = wikis(:multi_section)
    @wiki.lock! :document, @user
    @wiki.release_my_lock! :document, @user

    "should appear that no user is a locker_of document".tap do |msg|
      assert_nil @wiki.locker_of(:document), msg
    end

    "should appear that no user is a locker_of a subsection".tap do |msg|
      assert_nil @wiki.locker_of('section-one'), msg
    end

    "should appear the same to that user and to a different user".tap do |msg|
      assert_same_elements @wiki.sections_open_for(@user), @wiki.sections_open_for(@different_user), msg
      assert_same_elements @wiki.sections_locked_for(@user), @wiki.sections_locked_for(@different_user), msg
    end

    "should appear to a different user that all sections can be edited and none are locked".tap do |msg|
      assert_same_elements @wiki.sections_open_for(@different_user), @wiki.all_sections, msg
      assert @wiki.sections_locked_for(@different_user).empty?, msg
    end
  end

end

