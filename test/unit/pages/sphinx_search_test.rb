#
#
# A Sphinx specific test.
#
# This test is skipped if sphinx is not running.
#

require_relative 'test_helper'
require 'set'

class Pages::SphinxSearchTest < ActiveSupport::TestCase

  def self.helper_method(method); end

  include PathFinder::ControllerExtension

  fixtures :groups, :users, :memberships, :pages, :page_terms,
   :user_participations, :group_participations, :taggings, :tags

  ##
  ## Tests for various search parameters
  ##

  def try_many_sphinx_searches(user)
    searches = [
      ['/type/discussion', Proc.new {|p| p['type'] == "DiscussionPage"}],
      ['/created-by/blue/', Proc.new {|p| p.created_by_id == 4}],
      ['/created-by/blue/public', Proc.new {|p| p.created_by_id == 4 && p.public?}],
      ['/user/red', Proc.new {|p| p.participation_for_user(users(:red)) }],
      ['/group/rainbow', Proc.new {|p| groups(:rainbow).may?(:view,p)} ],
      ['/tag/joy/tag/disgust', Proc.new {|p| p.tag_list.include? "joy" and p.tag_list.include? "disgust"} ],
      ['/owned-by/person/blue', Proc.new {|p| p.owner_id == 4}]
    ]

    ##
    ## options_for_me
    ##

    searches.each do |search_str, search_code|
      #puts 'trying... %s' % search_str
      sphinx_pages = Page.find_by_path(
        search_str, options_for_me(:method => :sphinx, :per_page => 1000)
      )
      raw_pages = Page.all(:order => "updated_at DESC").select{ |p|
        search_code.call(p) && user.may?(:view, p)
      }
      assert raw_pages.any?, 'a filter with no results is a bad test'
      assert_equal page_ids(raw_pages), page_ids(sphinx_pages),
        "#{search_str} should match results for user"
    end

    ##
    ## options_for_group
    ##

    searches.each do |search_str, search_code|
      #puts 'trying... %s' % search_str
      sphinx_pages = Page.find_by_path(
        search_str, options_for_group(
          groups(:rainbow), :method => :sphinx, :per_page => 1000
        )
      )
      raw_pages = Page.find(:all).select{ |p|
        search_code.call(p) and groups(:rainbow).may?(:view, p) and user.may?(:view, p)
      }
      assert_equal page_ids(raw_pages), page_ids(sphinx_pages),
        "#{search_str} should match results for group"
    end
  end

  def test_sphinx_searches
    return unless sphinx_working?(:test_sphinx_searches)

    login(:blue)
    user = users(:blue)

    try_many_sphinx_searches user

=begin
    # the following test is not yet working
    ThinkingSphinx.deltas_enabled = true # will this make delta index active?
    # add some pages, and make sure that they appear in the sphinx search results
    (1..10).each do |i|
      p = Page.create :title => "new pending page #{i}"
      p.add user
      p.unresolve
      p.save
    end

    try_many_sphinx_searches user
=end

  end

  def test_sphinx_searches_different_user
    return unless sphinx_working?(:test_sphinx_searches)

    # orange has access to different pages (some vote pages, etc.)
    login(:orange)
    user = users(:orange)

    #try_many_sphinx_searches user
  end

  def test_sphinx_search_text_doc
    # return unless sphinx_working?(:test_sphinx_search_text_doc)

    # TODO: write this test
  end

  def xtest_sphinx_with_pagination
    return unless sphinx_working?(:test_sphinx_with_pagination)

    login(:blue)
    user = users(:blue)

    searches = [
      ['/descending/updated_at/limit/10', Proc.new {
        Page.find(:all, :order => "updated_at DESC").select{|p| user.may?(:view, p)}[0,10]
      }],
      ['/ascending/updated_at/limit/13', Proc.new {
        Page.find(:all, :order => "updated_at ASC").select{|p| user.may?(:view, p)}[0,13]
      }],
      ['/descending/created_at/limit/5', Proc.new {
        Page.find(:all, :order => "created_at DESC").select{|p| user.may?(:view, p)}[0,5]
      }],
      ['/ascending/created_at/limit/15', Proc.new {
        Page.find(:all, :order => "created_at ASC").select{|p| user.may?(:view, p)}[0,15]
      }],
   ]

    options = { :user_ids => [users(:blue).id], :group_ids => users(:blue).all_group_ids, :method => :sphinx }

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
    @current_user = UnauthenticatedUser.new
  end

  #
  # takes an array of Pages, UserParticipations, or GroupParticipations
  # and returns a Set of page ids. If a block is given, then the page
  # is passed to the block and if the block evaluates to false then
  # the page is not added to the set.
  #
  def page_ids(array)
    return Set.new() unless array.any?
    if array.first.instance_of?(UserParticipation) or array.first.instance_of?(GroupParticipation)
      Set.new(
        array.collect{|part|
          if block_given?
            part.page_id if yield(part.page)
          else
            part.page_id
          end
        }.compact
      )
    elsif array.first.is_a?(Page)
      Set.new(
        array.collect{|page|
          if block_given?
            page.id if yield(page)
          else
            page.id
          end
        }.compact
      )
    else
      puts 'error in page_ids(%s)' % array.class
      puts array.first.class.to_s
      puts caller().inspect
    end
  end
end