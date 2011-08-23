# require File.expand_path(File.dirname(__FILE__) + '/test_helper')
class RelationshipObserverTest < MiniTest::Unit::TestCase

  def setup
    ActiveRecord::Base.disconnect! :stub_associations => true, :strategy => :noop
  end

  def test_after_create_callback
    me = stub
    you = stub
    FriendActivity.expects(:find_twin).with(me, you)
    FriendActivity.expects(:create!).
      with(has_entries(:user => me, :other_user => you))
    rel = Relationship.new :user => me, :contact => you
    rel.type = 'Friendship'
    rel.save!
  end
end


