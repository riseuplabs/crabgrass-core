require 'test_helper'

class Page::AccessCodeTest < ActiveSupport::TestCase
  def test_create
    assert_difference 'Page::AccessCode.count' do
      Page::AccessCode.create! expires_at: 1.hour.ago
    end
    assert_difference 'Page::AccessCode.count' do
      Page::AccessCode.create! expires_at: 1.hour.from_now
    end

    assert_equal 2, Page::AccessCode.count

    Page::AccessCode.cleanup_expired

    assert_equal 1, Page::AccessCode.count
  end
end
