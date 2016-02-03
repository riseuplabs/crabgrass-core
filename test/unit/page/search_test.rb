#
#
# Tests that utilize the search_filters
#
# Some tests require that sphinx be running. These are skipped if it is not.
#

require 'test_helper'
require 'set'

class Page::SearchTest < ActiveSupport::TestCase

  def self.helper_method(method); end

  include PathFinder::ControllerExtension

  ##
  ## Tests for various search parameters
  ##

  # we can only test the title here as that is the only thing
  # mysql currently searches.
  def test_search_is_escaped
    login(:blue)
    assert_path_filters '/text/@test.me' do |page|
      page.title.try.include? "@test.me"
    end
  end

  def test_search_by_type
    login(:blue)
    assert_path_filters '/type/discussion' do |page|
      !page.deleted? && page['type'] == "DiscussionPage"
    end
  end

  def test_combined_search
    login(:blue)
    assert_path_filters '/created-by/blue/public' do |p|
      !p.deleted? && p.created_by_id == 4 && p.public?
    end
  end

  def test_search_by_other_user
    login(:blue)
    assert_path_filters '/user/red' do |p|
      !p.deleted? && p.participation_for_user(users(:red))
    end
  end

  def test_search_group_pages
    login(:blue)
    assert_path_filters '/group/rainbow' do |p|
      !p.deleted? && groups(:rainbow).pages.include?(p)
    end
  end

  def test_search_by_multiple_tags
    login(:blue)
    assert_path_filters '/tag/surprise/tag/anticipation' do |p|
      !p.deleted? &&
        p.tag_list.include?("surprise") &&
        p.tag_list.include?("anticipation")
    end
  end

  def test_search_by_ownership
    login(:blue)
    assert_path_filters '/owned-by/person/blue' do |p|
      !p.deleted? && p.owner_id == 4
    end
  end

  def test_search_deleted
    login(:blue)
    assert_path_filters '/deleted' do |p|
      p.deleted?
    end
  end

  #
  # Test a path filter within mysql and sphinx for a user and a group.
  #
  def assert_path_filters(path, &filter)
    methods = [:mysql]
    methods << :sphinx if sphinx_working?
    methods.each do |method|
      options = options_for_me(method: method, per_page:1000, context: current_user)
      my_filter = Proc.new {|page| filter.call(page) && current_user.may?(:view, page)}
      assert_path_filter(path, options, &my_filter)

      group = groups(:rainbow)
      options = options_for_group(group, method: method, per_page:1000, context: group)
      group_filter = Proc.new {|page| my_filter.call(page) && group.may?(:view, page)}
      assert_path_filter(path, options, &group_filter)
    end
    # we still run the mysql test but mark the test as skipped if sphinx is not on
    skip_with_sphinx_hints unless sphinx_working?
  end

  def assert_path_filter(path, options, &filter)
    context = options.delete :context
    searched_pages = Page.find_by_path(path, options)
    actual_pages = Page.order("updated_at DESC").to_a.select(&filter)
    assert actual_pages.any?,
      'a filter with no results is a bad test (user `%s`, context `%s`, filter `%s`)' %
      [current_user.name, context.name, path]
    actual_set = page_ids(actual_pages)
    searched_set = page_ids(searched_pages)
    assert actual_set == searched_set, <<-EOM
      #{path} query with #{options[:method]} should match results.
      user: #{current_user.name}, context: #{context.name}
      pages missing from result: #{(actual_set-searched_set).to_a.sort}
      extra pages in result: #{(searched_set-actual_set).to_a.sort}
    EOM
  end

  # def test_sphinx_delta_searches
    # the following test is not yet working
    #ThinkingSphinx.deltas_enabled = true # will this make delta index active?
    ## add some pages, and make sure that they appear in the sphinx search results
    #(1..10).each do |i|
    #  p = Page.create :title => "new pending page #{i}"
    #  p.add user
    #  p.unresolve
    #  p.save
    #end
    #
    #try_many_sphinx_searches user
  # end

  # def test_sphinx_searches_different_user
  #   return unless sphinx_working?(:test_sphinx_searches)
  #   # orange has access to different pages (some vote pages, etc.)
  #   login(:orange)
  #   user = users(:orange)
  #   #try_many_sphinx_searches user
  # end

  # def test_sphinx_search_text_doc
  #   # return unless sphinx_working?(:test_sphinx_search_text_doc)
  #   # TODO: write this test
  # end

  def xtest_sphinx_with_pagination
    return unless sphinx_working?(:test_sphinx_with_pagination)

    login(:blue)
    user = users(:blue)

    searches = [
      ['/descending/updated_at/limit/10', Proc.new {
        Page.find(:all, order: "updated_at DESC").select{|p| user.may?(:view, p)}[0,10]
      }],
      ['/ascending/updated_at/limit/13', Proc.new {
        Page.find(:all, order: "updated_at ASC").select{|p| user.may?(:view, p)}[0,13]
      }],
      ['/descending/created_at/limit/5', Proc.new {
        Page.find(:all, order: "created_at DESC").select{|p| user.may?(:view, p)}[0,5]
      }],
      ['/ascending/created_at/limit/15', Proc.new {
        Page.find(:all, order: "created_at ASC").select{|p| user.may?(:view, p)}[0,15]
      }],
   ]

    options = { user_ids: [users(:blue).id], group_ids: users(:blue).all_group_ids, method: :sphinx }

    searches.each do |search_str, search_code|
      sphinx_pages = Page.find_by_path(search_str, options)
      raw_pages = search_code.call
      assert_equal page_ids(raw_pages), page_ids(sphinx_pages), "#{search_str} should match results for user when paginated"
    end
  end

  protected

  #
  # controller-like stubs
  #
  def logged_in?
    @logged_in
  end

  def current_user
    @current_user
  end

  private

  #def controller
  #  self.controller ||= MockController.new
  #end

  def login(user = :blue)
    @logged_in = true
    @current_user = users(user)
  end

  def dont_login
    @logged_in = false
    @current_user = User::Unknown.new
  end

  #
  # takes an array of Pages, User::Participations, or GroupParticipations
  # and returns a Set of page ids. If a block is given, then the page
  # is passed to the block and if the block evaluates to false then
  # the page is not added to the set.
  #
  def page_ids(array)
    return Set.new() unless array.any?
    Set.new(
      array.collect{|record|

        if record.is_a?(Page)
          id, page = record, record.id
        else
          id, page = record.page_id, nil
        end

        if block_given?
          id if yield(page || Page.find(id))
        else
          id
        end
      }.compact
    )
  end

  def skip_with_sphinx_hints
    skip("To make thinking_sphinx tests not skip, try this:
  bundle exec rake db:schema:dump cg:test:update_fixtures
  bundle exec rake RAILS_ENV=test db:test:prepare db:fixtures:load ts:rebuild")
  end

  def sphinx_working?
    ThinkingSphinx::Configuration.instance.controller.running?
  end

end
