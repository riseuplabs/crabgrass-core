# require File.expand_path(File.dirname(__FILE__) + '/test_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')
require 'unit_record'
class RelationshipObserverTest < ActiveSupport::TestCase

  def setup
    @old_configurations = ActiveRecord::Base.configurations
    ActiveRecord::Base.disconnect! :stub_associations => true, :strategy => :noop
  end

  def teardown
    ActiveRecord::Base.configurations = @old_configurations
    ActiveRecord::Base.establish_connection
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


