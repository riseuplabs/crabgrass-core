require 'test_helper'

class Page::History::GrantGroupAccessTest < ActiveSupport::TestCase
  def test_subclass_translation_key
    history = Page::History::GrantGroupFullAccess.new
    assert_equal 'page_history_granted_group_full_access',
                 history.description_key
  end

  def test_translation_key_with_access
    part_stub = stub access_sym: :admin, group: nil
    history = Page::History::GrantGroupAccess.new(participation: part_stub)
    assert_equal 'page_history_granted_group_full_access',
                 history.description_key
  end

  def test_translation_key_without_access
    history = Page::History::GrantGroupAccess.new
    assert_equal 'page_history_granted_group_access',
                 history.description_key
  end

  def test_group_from_participation
    group = Group.new(full_name: 'Trees')
    part_stub = stub group: group, access_sym: nil
    history = Page::History::GrantGroupAccess.new(participation: part_stub)
    assert_equal group, history.item
    assert_description_params history,
                              user_name: 'Unknown/Deleted',
                              item_name: 'Trees'
  end

  def assert_description_params(history, params)
    assert_equal params, history.description_params
  end
end
