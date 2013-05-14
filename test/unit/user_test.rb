require_relative 'test_helper'

class UserTest < ActiveSupport::TestCase

  fixtures :users, :groups, :memberships

  def setup
    Time.zone = ActiveSupport::TimeZone["Pacific Time (US & Canada)"]
  end

  def test_user_fixtures_are_valid
    orange = users(:orange)
    orange.valid?
    assert_equal Hash.new, orange.errors
    assert orange.valid?
  end

  def test_email_required_settings
    assert !User.new.should_validate_email
    orange = users(:orange)
    orange.email = nil
    orange.valid?
    assert_equal Hash.new, orange.errors
    assert orange.valid?
  end

  def test_ensure_values_in_receive_notifications
    user = FactoryGirl.create(:user)

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
    FactoryGirl.create :user, :login => '2unlimited', :password => '3qasdb43!sdaAS...', :password_confirmation => '3qasdb43!sdaAS...'
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
    u = FactoryGirl.create :user, :login => '2unlimited', :password => '3qasdb43!sdaAS...', :password_confirmation => '3qasdb43!sdaAS...'
    assert !u.reload.wall_discussion.new_record?
  end

  def test_friends_or_peers_with_access
    red = users(:red)
    blue = users(:blue)

    assert !red.access?(red.associated(:friends) => :spy), 'this test assumes that friends cannot spy by default'

    red.grant_access!(blue => :spy)
    red.add_contact!(blue)

    with_access = User.with_access(blue => :spy).friends_or_peers_of(blue)
    assert_equal ['red'], with_access.all.map(&:login)
  end


  ## Tests for migrate_permissions!, in order:
  ## * public may :view ?
  ## * friends may :view ?
  ## * peers may :view ?
  ## * public may :see_contacts ?
  ## * friends may :see_contacts ?
  ## Assuming that the rest works as well then.

  def test_migrate_public_may_view
    user = create_user
    user.keys.destroy_all

    assert ! users(:blue).may?(:view, user), 'expected strangers not to be able to view a user without any keys set up'

    user.profiles.public.update_attributes!(
      :may_see => true
    )

    user.migrate_permissions!

    assert users(:blue).may?(:view, user), 'expected strangers to be able to view this user, after migrating permissions'

  end

  def test_migrate_friend_may_view
    # setup
    user = create_user
    user.add_contact!(users(:blue), :friend)
    groups(:animals).add_user!(user)
    user.revoke_access!(CastleGates::Holder[user.associated(:friends)] => :view)

    # check assumptions after setup
    assert users(:blue).friend_of?(user)
    assert users(:kangaroo).peer_of?(user)
    assert ! users(:red).friend_of?(user)
    assert ! users(:red).peer_of?(user)

    assert ! users(:blue).may?(:view, user), 'expected friends not to be able to view this user'

    user.profiles.public.update_attributes!(
      :may_see => false
    )
    user.profiles.private.update_attributes!(
      :may_see => true,
      :peer => false
    )

    user.migrate_permissions!

    assert users(:blue).may?(:view, user), 'expected friends to be able to view this user, after migrating permissions'
    assert ! users(:kangaroo).may?(:view, user), 'expected peers not to be able to view this user, after migrating permissions'
    assert ! users(:red).may?(:view, user), 'expected strangers not to be able to view this user, after migrating permissions'

  end

  def test_migrate_peer_may_view
    user = create_user
    groups(:animals).add_user!(user)
    user.revoke_access!(CastleGates::Holder[user.associated(:peers)] => :view)

    assert user.member_of?(groups(:animals))
    assert user.peer_of?(users(:kangaroo))

    assert ! users(:kangaroo).may?(:view, user), 'expected peers not to be able to view this user'

    user.profiles.public.update_attributes!(
      :may_see => false
    )
    user.profiles.private.update_attributes!(
      :may_see => true,
      :peer => true
    )

    user.migrate_permissions!

    assert users(:kangaroo).may?(:view, user), 'expected peers to be able to view this user after migration'
    assert ! users(:red).may?(:view, user), 'expected strangers not to be able to view this user after migration'
  end

  def test_migrate_public_may_see_contacts
    user = create_user
    user.keys.destroy_all

    assert ! users(:blue).may?(:see_contacts, user), 'expected strangers not to be able to see the contacts of a user without any keys set up'

    user.profiles.public.update_attributes!(
      :may_see_contacts => true
    )

    user.migrate_permissions!

    assert users(:blue).may?(:see_contacts, user), 'expected strangers to be able to see contacts of this user, after migrating permissions'
  end

  def test_migrate_friend_may_see_contacts
    # setup
    user = create_user
    user.add_contact!(users(:blue), :friend)
    user.revoke_access!(CastleGates::Holder[user.associated(:friends)] => :see_contacts)

    assert ! users(:blue).may?(:see_contacts, user), 'expected friends not to be able to see the contacts of this user'

    user.profiles.public.update_attributes!(
      :may_see_contacts => false
    )
    user.profiles.private.update_attributes!(
      :may_see_contacts => true,
      :peer => false
    )

    user.migrate_permissions!

    assert users(:blue).may?(:see_contacts, user), 'expected friends to be able to see contacts of this user, after migrating permissions'
    assert ! users(:red).may?(:see_contacts, user), 'expected strangers not to be able to see contacts of this user, after migrating permissions'
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
