require File.dirname(__FILE__) + '/test_helper'

class UserTest < ActiveSupport::TestCase

  fixtures :users, :groups, :memberships

  def setup
    Time.zone = ActiveSupport::TimeZone["Pacific Time (US & Canada)"]
  end

  def test_ensure_values_in_receive_notifications
    user = User.make

    user.receive_notifications = nil
    user.save!
    assert_equal nil, user.receive_notifications

    user.receive_notifications = true
    user.save!
    assert_equal nil, user.receive_notifications

    user.receive_notifications = false
    user.save!
    assert_equal nil, user.receive_notifications

    user.receive_notifications = "Any"
    user.save!
    assert_equal nil, user.receive_notifications

    user.receive_notifications = "Digest"
    user.save!
    assert_equal "Digest", user.receive_notifications

    user.receive_notifications = "Single"
    user.save!
    assert_equal "Single", user.receive_notifications

    user.receive_notifications = ""
    user.save!
    assert_equal nil, user.receive_notifications
  end

  ## ensure that a user and a group cannot have the same handle
  def test_namespace
    assert_no_difference 'User.count' do
      u = create_user(:login => 'groups')
      assert u.errors.on(:login)
    end

    g = Group.create :name => 'robot-overlord'
    assert_no_difference 'User.count' do
      u = create_user(:login => 'robot-overlord')
      assert u.errors.on(:login)
    end
  end

  def test_associations
    User.current = users(:blue)
    assert check_associations(User)
    User.current = nil
  end

  def test_alphabetized
    assert_equal User.all.size, User.alphabetized('').size

    # find numeric group names
    assert_equal 0, User.alphabetized('#').size
    User.create! :login => '2unlimited', :password => '3qasdb43!sdaAS...', :password_confirmation => '3qasdb43!sdaAS...'
    assert_equal 1, User.alphabetized('#').size

    # case insensitive
    assert_equal User.alphabetized('G').size, User.alphabetized('g').size

    # nothing matches
    assert User.alphabetized('z').empty?
  end

  def test_peers_of
    u = users(:blue)
    assert_equal u.peers, User.peers_of(u)
  end

  def test_removal_deletes_chat_channels_users
    user = create_user
    user_id = user.id

    group1 = groups(:true_levellers)
    group1.add_user! user
    channel1 = ChatChannel.create(:name => group1.name, :group_id => group1.id)
    ChatChannelsUser.create({:channel => channel1, :user => user})

    group2 = groups(:rainbow)
    group2.add_user! user
    channel2 = ChatChannel.create(:name => group2.name, :group_id => group2.id)
    ChatChannelsUser.create({:channel => channel2, :user => user})

    user.destroy
    assert ChatChannelsUser.find(:all, :conditions => {:user_id => user_id}).empty?
  end

  def test_new_user_has_discussion
    u = User.create! :login => '2unlimited', :password => '3qasdb43!sdaAS...', :password_confirmation => '3qasdb43!sdaAS...'
    assert !u.reload.wall_discussion.new_record?
  end

  def test_friends_or_peers_with_access
    users(:red).grant_access!(users(:blue) => :view)
    users(:red).add_contact!(users(:blue))
    accessible = User.with_access(users(:blue) => :view).friends_or_peers_of(users(:blue))
    assert_equal users(:red), accessible.first
  end

  #
  # creating users no longer adds keys
  #
  #def test_user_creation_adds_keys
  #  assert_difference 'Key.count', 3 do
  #    user = User.make
  #  end
  #end

  protected

  def create_user(options = {})
    User.create({ :login => 'mrtester', :email => 'mrtester@riseup.net', :password => 'test', :password_confirmation => 'test' }.merge(options))
  end

end
