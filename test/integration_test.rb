require_relative 'test_helper'
require 'capybara/rails'
require "active_support/testing/setup_and_teardown"

class IntegrationTest < MiniTest::Unit::TestCase
  include Capybara::DSL

  protected

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

  def assert_login_failed
    assert_content :login_failed.t
    assert_content :login_failure_reason.t
  end

  def cleanup_user
    if @user
      User.find_by_login(@user.login).try.destroy
    end
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

