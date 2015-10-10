require 'test_helper'

class Page::BaseTest < ActiveSupport::TestCase

  fixtures :pages, :users, :groups, :polls

  def setup
    PageHistory.delete_all
  end

  def teardown
    PageHistory.delete_all
    # ensure there are no tempfiles left and getting removed
    # some random time.
    GC.start
  end

  def test_page_history_order
    user = users(:blue)
    page = WikiPage.create! owner: user, title: 'history'
    action_1 = PageHistory::AddStar.create!(page: page, user: user, created_at: "2007-10-10 10:10:10")
    action_2 = PageHistory::RemoveStar.create!(page: page, user: user, created_at: "2008-10-10 10:10:10")
    action_3 = PageHistory::StartWatching.create!(page: page, user: user, created_at: "2009-10-10 10:10:10")
    assert_equal action_1, page.page_histories[2]
    assert_equal action_2, page.page_histories[1]
    assert_equal action_3, page.page_histories[0]
  end

  def test_unique_names
    user = users(:red)
    group = groups(:rainbow)

    assert_nothing_raised do
      p1 = WikiPage.create!(title: 'title', name: 'unique', share_with: group, user: user)
    end

    assert_raises ActiveRecord::RecordInvalid, 'duplicate names should not be allowed' do
      p2 = WikiPage.create!(title: 'title', name: 'unique', share_with: group, user: user)
    end
  end

  def test_unique_names_with_recipients
    user = users(:penguin)

    params = ParamHash.new("title"=>"beet", "owner"=>user, "user"=>user, "share_with"=>{user.login=>{"access"=>"admin"}})

    assert_difference 'Page.count' do
      assert_difference 'PageTerms.count' do
        assert_difference 'User::Participation.count' do
          WikiPage.create!(params)
        end
      end
    end

    assert_no_difference 'Page.count', 'no new page' do
      assert_no_difference 'PageTerms.count', 'no new page terms' do
        assert_no_difference 'User::Participation.count', 'no new user part' do
          assert_raises ActiveRecord::RecordInvalid do
            WikiPage.create!(params)
          end
        end
      end
    end

  end

  def test_build
    user = users(:kangaroo)
    page = nil
    assert_no_difference 'Page.count', 'no new page' do
      assert_no_difference 'PageTerms.count', 'no new page terms' do
        assert_no_difference 'User::Participation.count', 'no new user part' do
          page = WikiPage.build!(title: 'hi', user: user)
        end
      end
    end
    assert_difference 'Page.count' do
      assert_difference 'PageTerms.count' do
        assert_difference 'User::Participation.count' do
          page.save
        end
      end
    end
  end

  # this is a test if we are using has_many_polymorphic
  # currently, we are using a single belongs_to that is polymorphic
  # for the relationship from page -> tool.
  def disabled_test_multi_tool
    @page = create_page title: 'this is a very fine test page'
    assert @page.tools.blank?
    assert @page.tools.push(@discussion)
    assert @page.tools.push(Discussion.create)
    assert_equal @page_tool_count += 2, @page.tools.length
    assert @page.tools.first.id == @discussion.id
    assert_equal 2, @page.discussions.length
    assert_equal 1, @discussion.pages.length
    assert @discussion.pages.first.title == @page.title, 'page title must match'
    assert @discussion.page.title == @page.title
  end

  def test_tool
    page = create_page title: 'what is for lunch?'
    assert poll = Poll.create
    assert poll.valid?, poll.errors.full_messages.to_s
    page.data = poll
    page.save
    assert_equal poll.page, page
    assert_equal page.data, poll
  end

  def test_discussion
    @page = WikiPage.create! title: 'this is a very fine test page'
    assert discussion = Discussion.create
    assert discussion.valid?, discussion.errors.full_messages.to_s
    #discussion.pages << @page
    @page.discussion = discussion
    @page.save
    #discussion.save
    #discussion.reload
    assert_equal discussion.page, @page
    assert_equal @page.discussion, discussion
  end


  def test_user_associations
    @page = create_page title: 'this is a very fine test page'
    user = User.find 3
    @page.created_by = user
    @page.save
    assert_not_nil @page.created_by
    assert_nil @page.updated_by
    #assert user.pages_created.first == @page

    @page.updated_by = user
    @page.save
    #assert user.pages_updated.first == @page

  end

  def test_denormalized
    group = groups(:animals)
    page = Page.create! owner: group, title: 'oak tree'
    assert_equal group.name, page.owner_name, 'page should have a denormalized copy of the group name'
  end

  def test_destroy
    page = RateManyPage.create! title: 'short lived', data: Poll.new
    poll_id = page.data.id
    page.destroy
    assert_equal nil, Poll.find_by_id(poll_id), 'the page data must be destroyed with the page'
  end

  def test_delete_and_undelete
    page = RateManyPage.create! title: 'longer lived', data: Poll.new
    poll_id = page.data.id
    assert_equal FLOW[:normal], page.flow,
      'a new page should have normal flow'
    page.delete
    assert_equal FLOW[:deleted], page.flow
    assert_equal Poll.find_by_id(poll_id), page.data,
      'the page data must be preserved when deleting the page'
    page.undelete
    assert_equal FLOW[:normal], page.flow,
      'undeleting a page should turn it back to flow nil'
  end

=begin
  def test_page_links
    p1 = create_page :title => 'red fish'
    p2 = create_page :title => 'two fish'
    p3 = create_page :title => 'blue fish'

    p1.add_link p2
    assert_equal p1.links.length, 1
    assert_equal p2.links.length, 1
    assert_equal p1.links.first.title, p2.title
    assert_equal p2.links.first.title, p1.title

    p1.add_link p3
    assert_equal p1.links.length, 2
    assert_equal p3.links.length, 1
    assert p1.links.include?(p3)

    p1.add_link p3
    p1.add_link p3
    p1.save
    assert_equal 2, p1.links.length, 'shouldnt be able to add same link twice'

    p2.destroy
    assert_equal 1, p1.links.length, 'after destroy, links should be removed'
  end
=end

  def test_associations
    assert check_associations(Page)
  end

  #  def test_thinking_sphinx
  #    if Page.included_modules.include? ThinkingSphinx::ActiveRecord
  #      page = Page.new :title => 'title'
  #      page.expects(:save_without_after_commit_callback)
  #      page.save
  #    else
#      puts "thinking sphinx is not included"
#    end
#  end

  def test_page_owner
    page = nil
    assert_nothing_raised do
      page = DiscussionPage.create! title: 'x', owner: 'green'
    end
    assert_equal users(:green), page.owner
    assert users(:green).may?(:admin, page)

    page.update_attributes({owner: users(:blue)})
    page.reload
    assert_equal users(:blue), page.owner, 'owner can be changed'
  end

  def test_page_owner_and_others
    page = nil
    assert_nothing_raised do
      page = DiscussionPage.create! title: 'x', user: users(:blue), owner: 'blue', share_with: {"green"=>{access: "edit"}}, access: :view
    end
    assert_equal users(:blue), page.owner
    assert users(:green).may?(:edit, page)
  end

  def test_page_default_owner
    Conf.ensure_page_owner = false
    page = Page.create! title: 'x', user: users(:blue),
      share_with: groups(:animals), access: :admin
    assert_nil page.owner_name
    assert_nil page.owner_id

    Conf.ensure_page_owner = true
    page = Page.create! title: 'x', user: users(:blue),
      share_with: groups(:animals), access: :admin
    assert_equal groups(:animals).name, page.owner_name
    assert_equal groups(:animals).id, page.owner_id
    assert_equal groups(:animals), page.owner
  end

  def test_update_at_updated_by_certain_fields
    page = create_page
    last_updated_at = page.updated_at

    page.save!
    assert_equal page.updated_at, last_updated_at

    page.update_attribute :resolved, !page.resolved
    assert_equal page.updated_at, last_updated_at

    page.update_attribute :public, !page.public
    assert_equal page.updated_at, last_updated_at

    page.update_attribute :created_by_id, rand(500)
    assert_equal page.updated_at, last_updated_at

    page.update_attribute :updated_by_id, rand(500)
    assert_equal page.updated_at, last_updated_at

    page.update_attribute :site_id, rand(500)
    assert_equal page.updated_at, last_updated_at

    page.update_attribute :stars_count, rand(500)
    assert_equal page.updated_at, last_updated_at

    page.update_attribute :views_count, rand(500)
    assert_equal page.updated_at, last_updated_at
  end

  def test_even_with_timestamps_disabled_it_should_timestamp_when_create
    page = create_page created_at: nil, updated_at: nil
    assert_not_nil page.created_at
    assert_not_nil page.updated_at
  end

  protected

  def create_page(options = {})
    defaults = {title: 'untitled page', public: false}
    Page.create!(defaults.merge(options))
  end

  def build_page(options = {})
    defaults = {title: 'untitled page', public: false}
    Page.build!(defaults.merge(options))
  end
end

