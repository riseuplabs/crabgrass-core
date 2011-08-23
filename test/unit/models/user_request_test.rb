# require File.expand_path(File.dirname(__FILE__) + '/test_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')
require 'minitest/autorun'
class UserRequestTest < ActiveSupport::TestCase

  def setup
    @old_configurations = ActiveRecord::Base.configurations
    ActiveRecord::Base.disconnect! :stub_associations => true, :strategy => :noop
  end

  def teardown
    ActiveRecord::Base.configurations = @old_configurations
    ActiveRecord::Base.establish_connection
  end

  def test_destroyed_if_recipient_destroyed
    me = stub
    you = User.build :name => "request me"
    req = RequestToFriend.create!(:created_by => me, :recipient => you)
    you.destroy
    assert_raises ActiveRecord::RecordNotFound, 'request should have been destroyed' do
      Request.find(req.id)
    end

    insider  = users(:dolphin)
    outsider = users(:gerrard)
    group    = groups(:animals)

    req = RequestToJoinUs.create(
      :created_by => insider, :recipient => outsider, :requestable => group)

    group.destroy_by(insider)
    assert_raises ActiveRecord::RecordNotFound, 'request should have been destroyed' do
      Request.find(req.id)
    end
  end

  def test_associations
    assert check_associations(Request)
  end

end

