require 'test_helper'

class PageUpdateNoticeTest < ActiveSupport::TestCase
  fixtures :users

  def setup
    @blue, @orange = users(:blue), users(:orange)
    create_page_for_user @blue
  end

  def teardown
    @page.destroy if @page
  end

  def test_simple_page_update_displays_notice_for_each_watcher
    assert_created do
      @page.add_post @blue, { body: 'comment' }
    end
    Notice.last.dismiss!

    watch_page @orange, @page
    assert_created 2 do
      @page.add_post @orange, { body: 'comment' }
    end
  end

  def test_multiply_updates_by_one_user_updates_timestamp_of_notice
    old_notice = nil

    assert_created do
      @page.add_post @blue, { body: 'comment1' }
      old_notice = Notice.last
      # miliseconds are ignored during database retrive?!
      sleep(1)
      @page.add_post @blue, { body: 'comment2' }
    end

    assert_not_equal old_notice.updated_at, Notice.last.updated_at
  end

  def test_multiply_updates_by_many_users_create_just_one_notice
    watch_page @orange, @page
    # each user recieves notification for the first page update
    assert_created 4 do
      @page.add_post @blue, { body: 'comment1' }
      @page.add_post @orange, { body: 'comment2' }
    end

    # but not for the second from same user
    assert_created 0 do
      @page.add_post @blue, { body: 'comment1' }
      @page.add_post @orange, { body: 'comment2' }
    end
  end

  def test_right_title_for_single_update
    @page.add_post @blue, { body: 'comment' }
    title = I18n.t("page_updated", { from: @blue.name, page_title: @page.title }).html_safe

    assert_equal title, Notice.last.display_title
  end

  def test_right_title_for_multiply_updates_by_one_user
    @page.add_post @blue, { body: 'comment1' }
    @page.add_post @blue, { body: 'comment2' }
    title = I18n.t(:page_updated, { from: @blue.name, page_title: @page.title }).html_safe

    assert_equal title, Notice.last.display_title
  end

  private

  def assert_created(count = 1, &block)
    assert_difference 'Notice::PageUpdateNotice.count', count, &block
  end

  def create_page_for_user(owner)
    @page = DiscussionPage.create!({
      name: "#{owner.login}_page_#{Time.now.to_i}",
      title: "owned by #{owner.login}",
      summary: 'Test page for cool users',
      owner: owner,
      user: owner
    })

    watch_page owner, @page
  end

  def watch_page(user, page)
    page.add user, watch: true
    page.save
  end

end
