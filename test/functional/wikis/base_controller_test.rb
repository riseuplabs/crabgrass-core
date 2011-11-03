require File.dirname(__FILE__) + '/../../test_helper'

class Wikis::BaseControllerTest < ActionController::TestCase

  def test_initializing_wiki_for_group
    group = stub
    wiki = stub :pages => [], :group => group
    Wiki.expects(:find).with(3).returns(wiki)
    run_before_filters nil, :wiki_id => 3
    assert_equal wiki, assigned(:wiki)
    assert_equal group, assigned(:group)
  end

  protected

  def run_before_filters(action=nil, params = {})
    @controller.stubs(:action_name).returns(action) if action
    @controller.stubs(:params).returns(params)
    session = ActionController::TestSession.new
    @controller.stubs(:session).returns(session)
    chain = @controller.class.filter_chain
    @controller.send :run_before_filters, chain, 0, 0

  end

  def assigned(name)
    @controller.instance_variable_get("@#{name}")
  end

end
