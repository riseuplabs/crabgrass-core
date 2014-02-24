require_relative 'test_helper'
require 'capybara/rails'
require "active_support/testing/setup_and_teardown"

# require all integration helpers
Dir[File.dirname(__FILE__) + '/helpers/integration/*.rb'].each do |file|
  require file
end

class IntegrationTest < MiniTest::Unit::TestCase
  include Capybara::DSL
  include RecordTracking
  include ContentAssertions
  include AccountManagement
  include UserRecords

  protected

  def teardown
    super
  ensure
    Capybara.reset_sessions!
  end

  def group
    records[:group] ||= FactoryGirl.create(:group)
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

