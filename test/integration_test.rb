require_relative 'test_helper'
require 'capybara/rails'
require "active_support/testing/setup_and_teardown"

class IntegrationTest < MiniTest::Unit::TestCase
  include Capybara::DSL

  protected

  # keep track of all records created
  attr_accessor :records

  def setup
    super
    @records = {}
  end

  def teardown
    @records.each_value do |record|
      # destroy is protected for groups. We want to use
      # it never the less as we do not care who destroyed it.
      record.send :destroy
    end
  rescue
  ensure
    Capybara.reset_sessions!
    super
  end

  def assert_content(content)
    assert page.has_content?(content), "Could not find '#{content}'"
  end

  def signup
    @user ||= FactoryGirl.build :user
    @user.display_name = nil
    click_on :signup_link.t
    fill_in :signup_login_name.t, with: @user.login
    fill_in :signup_password.t, with: @user.password
    fill_in :signup_confirm_password.t, with: @user.password
    click_on :signup_button.t
  end

  def login
    # Create a user wihtout the lengthy signup procedure
    @user ||= FactoryGirl.create :user
    visit '/' unless page.current_path == '/'
    fill_in :login_name.t, with: @user.login
    fill_in :login_password.t, with: @user.password
    click_on :login_button.t
  end

  def logout
    click_on :menu_link_logout.t(user: @user.display_name)
  end

  def destroy_account
    click_on :settings.t
    click_on :destroy.t
    click_button :destroy.t
  end

  # this function can take a single user as the argument and will
  # log you in as that user and run te code block.
  # It also takes an array of users and does so for each one in turn.
  def as_a(users,&block)
    if users.respond_to? :each
      users.each{ |user| as_a(user, &block) }
    else
      run_for_user(users, &block)
    end
  end

  def run_for_user(current_user, &block)
    @run ||= 0
    @run += 1
    @user = current_user
    login unless @user.is_a? UnauthenticatedUser
    block.arity == 1 ? yield(@user) : yield
    Capybara.reset_sessions!
  rescue MiniTest::Assertion => e
    # preserve the backtrace but add the run number to the message
    raise $!, "#{$!} in run #{@run}", $!.backtrace
  end

  def hidden_user
    records[:hidden_user] ||= FactoryGirl.create(:user).tap do |hide|
      hide.revoke_access! :friends => :view
      hide.revoke_access! :peers => :view
    end
  end

  def public_user
    records[:public_user] ||= FactoryGirl.create(:user).tap do |pub|
      pub.grant_access! :public => :view
    end
  end

  def user
    records[:user] ||= FactoryGirl.create :user
  end

  def other_user
    records[:other_user] ||= FactoryGirl.create :user
  end

  def visitor
    UnauthenticatedUser.new
  end

  def friend_of(other)
    FactoryGirl.create(:user).tap do |friend|
      other.add_contact!(friend, :friend)
    end
  end

  def peer_of(other)
    FactoryGirl.create(:user).tap do |peer|
      group.add_user! other
      group.add_user! peer
    end
  end

  def group
    records[:group] ||= FactoryGirl.create(:group)
  end

  def assert_landing_page(owner)
    assert_content owner.display_name
  end

  def assert_not_found(thing = nil)
    thing ||= :page.t
    assert_content :thing_not_found.t(thing: thing)
  end

  def assert_login_failed
    assert_content :login_failed.t
    assert_content :login_failure_reason.t
  end

  def cleanup_user
    if @user
      User.find_by_login(@user.login).try.destroy
    end
    @user = nil
  end

  def create_page(type)
    @page ||= FactoryGirl.create type
    type_name = I18n.t "#{type}_display"
    # create page is on a hidden dropdown
    # click_on :create_page.t
    visit '/pages/new/me'
    click_on type_name
    fill_in(:title.t, with: @page.title) if @page.title
    fill_in(:summary.t, with: @page.summary) if @page.summary
    click_on :create.t
  end

  def assert_page_header
    within '#title h1' do
      assert_content @page.title
    end
  end

  def cleanup_page
    if @page
      Page.find_by_name(@page.name).try.destroy
    end
    @page = nil
  end

end

# fix a rack issue that only comes up with rack < 1.3.0 and capybara
module Rack
  module Utils
    def escape(s)
      CGI.escape(s.to_s)
    end
    def unescape(s)
      CGI.unescape(s)
    end
  end
end

