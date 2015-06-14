require_relative 'test_helper'

class PageTrackingObserverTest < ActiveSupport::TestCase

  def setup
    Page.delete_all
    @pepe = FactoryGirl.create(:user, login: "pepe")
    @manu = FactoryGirl.create(:user, login: "manu")
    @manu.grant_access!(public: :pester)
    User.current = @pepe
    @page = FactoryGirl.create(:page, owner: @pepe)
    @last_count = @page.page_histories.count
  end

  def teardown
    Page.delete_all
  end

  def test_save_page_without_modifications
    @page.save!
    assert_equal @last_count, @page.page_histories.count
  end

  def test_change_page_title
    @page.title = "Other title"
    @page.save!
    assert_equal @last_count + 1, @page.page_histories.count
    assert_equal @pepe, PageHistory.last.user
    assert_equal PageHistory::ChangeTitle, PageHistory.last.class
  end

  def test_add_star
    @upart = @page.add(@pepe, star: true ).save!
    @page.reload
    assert_equal @last_count + 1, @page.page_histories.count
    assert_equal @pepe, PageHistory.last.user
    assert_equal PageHistory::AddStar, PageHistory.last.class
  end

  def test_remove_star
    @upart = @page.add(@pepe, star: true).save!
    @upart = @page.add(@pepe, star: nil).save!
    @page.reload
    assert_equal @last_count + 2, @page.page_histories.count
    assert_equal @pepe, PageHistory.last.user
    assert_equal PageHistory::RemoveStar, PageHistory.last.class
  end

  def test_mark_as_public
    @page.public = true
    @page.save
    assert_equal @last_count + 1, @page.page_histories.count
    assert_equal @pepe, PageHistory.last.user
    assert_equal PageHistory::MakePublic, PageHistory.last.class
  end

  def test_mark_as_private
    @page.public = false
    @page.save
    assert_equal @last_count + 1, @page.page_histories.count
    assert_equal @pepe, PageHistory.last.user
    assert_equal PageHistory::MakePrivate, PageHistory.last.class
  end

  def test_page_deleted
    @page.delete
    assert_equal @last_count + 1, @page.page_histories.count
    assert_equal @pepe, PageHistory.last.user
    assert_equal PageHistory::Deleted, PageHistory.last.class
  end

  def test_add_tag
    true
  end

  def test_remove_tag
    true
  end

  def test_add_attachment
    true
  end

  def test_remove_attachment
    true
  end

  def test_create_page
    page = FactoryGirl.create(:page, owner: @pepe)
    page.reload
    assert_equal PageHistory::PageCreated, page.page_histories.first.class
    assert_equal PageHistory::GrantUserFullAccess, page.page_histories.last.class
  end

  def test_start_watching
    @upart = @page.add(@pepe, watch: true).save!
    @page.reload
    assert_equal @last_count + 1, @page.page_histories.count
    assert_equal @pepe, PageHistory.last.user
    assert_equal PageHistory::StartWatching, PageHistory.last.class
  end

  def test_stop_watching
    @upart = @page.add(@pepe, watch: true).save!
    @page.reload
    @upart = @page.add(@pepe, watch: nil).save!
    @page.reload
    assert_equal @last_count + 2, @page.page_histories.count
    assert_equal @pepe, PageHistory.last.user
    assert_equal PageHistory::StopWatching, PageHistory.last.class
  end

  def test_share_page_with_user_assigning_full_access
    @pepe.share_page_with!(@page, [@manu.login], {access: 1})
    assert_equal @last_count + 1, @page.page_histories.count
    assert_equal @pepe, PageHistory.last.user
    assert_equal PageHistory::GrantUserFullAccess, PageHistory.last.class
    assert_equal User, PageHistory.last.item.class
  end

  def test_share_page_with_user_assigning_write_access
    @pepe.share_page_with!(@page, [@manu.login], {access: 2})
    assert_equal @last_count + 1, @page.page_histories.count
    assert_equal @pepe, PageHistory.last.user
    assert_equal PageHistory::GrantUserWriteAccess, PageHistory.last.class
    assert_equal User, PageHistory.last.item.class
  end

  def test_share_page_with_user_assigning_read_access
    @pepe.share_page_with!(@page, [@manu.login], {access: 3})
    assert_equal @last_count + 1, @page.page_histories.count
    assert_equal @pepe, PageHistory.last.user
    assert_equal PageHistory::GrantUserReadAccess, PageHistory.last.class
    assert_equal User, PageHistory.last.item.class
  end

  def test_share_page_with_user_removing_access
    @pepe.share_page_with!(@page, [@manu.login], {access: 3})
    @page.user_participations.last.destroy
    assert_equal @last_count + 2, @page.page_histories.count
    assert_equal @pepe, PageHistory.last.user
    assert_equal PageHistory::RevokedUserAccess, PageHistory.last.class
    assert_equal User, PageHistory.last.item.class
  end

  def test_share_page_with_group_assigning_full_access
    group = FactoryGirl.create :group
    group.add_user! @pepe
    @pepe.share_page_with!(@page, group, access: 1)
    assert_equal @last_count + 1, @page.page_histories.count
    assert_equal @pepe, PageHistory.last.user
    assert_equal PageHistory::GrantGroupFullAccess, PageHistory.last.class
    assert_equal Group, PageHistory.last.item.class
  end

  def test_share_page_with_group_assigning_write_access
    group = FactoryGirl.create(:group)
    group.add_user! @pepe
    @pepe.share_page_with!(@page, group, access: 2)
    assert_equal @last_count + 1, @page.page_histories.count
    assert_equal @pepe, PageHistory.last.user
    assert_equal PageHistory::GrantGroupWriteAccess, PageHistory.last.class
    assert_equal Group, PageHistory.last.item.class
  end

  def test_share_page_with_group_assigning_read_access
    group = FactoryGirl.create(:group)
    group.add_user! @pepe
    @pepe.share_page_with!(@page, group, access: 3)
    assert_equal @last_count + 1, @page.page_histories.count
    assert_equal @pepe, PageHistory.last.user
    assert_equal PageHistory::GrantGroupReadAccess, PageHistory.last.class
    assert_equal Group, PageHistory.last.item.class
  end

  def test_share_page_with_group_removing_access
    group = FactoryGirl.create(:group)
    group.add_user! @pepe
    @pepe.share_page_with!(@page, group, access: 3)
    @page.group_participations.last.destroy
    assert_equal @last_count + 2, @page.page_histories.count
    assert_equal @pepe, PageHistory.last.user
    assert_equal PageHistory::RevokedGroupAccess, PageHistory.last.class
    assert_equal Group, PageHistory.last.item.class
  end

  def test_update_content
    page = FactoryGirl.create(:wiki_page, data: Wiki.new(user: @pepe, body: ""))
    # for some reason creating the page didn't create a GrantUserFullExist history
    # item. Instead that would be created as soon as the wiki is updated (because
    # that triggers a page.save! to update the page terms). The GrantUserFullAccess
    # item would then be created *after* the UpdatedContent item, which breaks this
    # test. Saving the page here makes everything work as expected again.
    page.save!
    wiki = Wiki.find page.data_id
    previous_page_history = page.page_histories.count
    wiki.update_section!(:document, @pepe, 1, "dsds")
    assert_equal PageHistory::UpdatedContent, PageHistory.last.class
    assert_equal previous_page_history + 1, page.page_histories.count
    assert_equal @pepe, PageHistory.last.user
  end

  def test_page_destroyed
    # hmm we need to figure out another way to store this action
    # to be notified since when the page record is destroyed all
    # hisotries are destroyed too
    true
  end

end
