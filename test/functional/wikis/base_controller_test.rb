require File.dirname(__FILE__) + '/../test_helper'

class Wikis::BaseControllerTest < ActionController::TestCase

  def test_initializing_wiki_for_group
    group = Group.make
    wiki = stub :page => nil, :group => group, :context => group
    Wiki.expects(:find).with(3).returns(wiki)
    run_before_filters nil, :wiki_id => 3
    assert_equal wiki, assigned(:wiki)
    assert_equal group, assigned(:group)
  end

end
