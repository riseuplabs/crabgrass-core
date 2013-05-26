require File.dirname(__FILE__) + '/../test_helper'

class Wikis::BaseControllerTest < ActionController::TestCase

  def xtest_initializing_wiki_for_group
    group  = FactoryGirl.create(:group)
    wiki = stub :page => nil, :group => group, :context => group
    Wiki.expects(:find).with(3).returns(wiki)
    @controller.stubs(:params).returns(:wiki_id => 3)
    @controller.send :fetch_wiki
    assert_equal wiki, assigned(:wiki)
    assert_equal group, assigned(:wiki).context
  end

end
