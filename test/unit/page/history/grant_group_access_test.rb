require 'test_helper'

class Page::History::GrantGroupAccessTest < ActiveSupport::TestCase
  def test_subclass_translation_key
    history = Page::History::GrantGroupFullAccess.new
    assert_equal 'page_history_granted_group_full_access',
                 history.description_key
  end

  def test_group_from_participation
    history = Page::History::GrantGroupAccess.new participation: part_stub
    assert_equal 'page_history_granted_group_write_access',
                 history.description_key
    assert_equal part_stub.group, history.item
    assert_description_params history,
                              user_name: 'Unknown/Deleted',
                              item_name: 'Trees'
  end

  def assert_description_params(history, params)
    assert_equal params, history.description_params
  end

  def part_stub
    @part_stub ||= Object.new.tap do |part|
      def part.group
        @group ||= Group.new(full_name: 'Trees')
      end
      def part.access_sym
        :edit
      end
    end
  end
end
