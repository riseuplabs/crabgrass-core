require 'test_helper'

class Activity::Test < ActiveSupport::TestCase
  def setup
    @blue = users(:blue)
    @red = users(:red)
    @group = groups(:rainbow)
  end

  def test_contact
    assert_difference 'Activity.count', 2 do
      Activity::Friend.create! user: @blue, other_user: @red
    end
    act = Activity::Friend.for_me(@blue).last
    assert act, 'there should be a friend activity created'
    assert_equal @blue, act.user
    assert_equal @red, act.other_user
  end

  def test_group_created
    act = Activity::GroupCreated.new group: @group, user: @red
    assert_activity_for_user_group(act, @red, @group)

    act = Activity::UserCreatedGroup.new group: @group, user: @red
    assert_activity_for_user_group(act, @red, @group)
  end

  def test_create_membership
    ruth = FactoryGirl.create(:user)
    @group.add_user!(ruth)
    Tracking::Action.track :create_membership, group: @group, user: ruth

    act = Activity::UserJoinedGroup.for_all(@red).find_by_subject_id(ruth.id)
    assert_nil act, "The new peers don't get UserJoinedGroupActivities."

    act = Activity::GroupGainedUser.for_all(@red).last
    assert_equal @group.id, act.group.id,
                 'New peers should get GroupGainedUserActivities.'

    act = Activity::GroupGainedUser.for_group(@group, ruth).last
    assert_equal Activity::GroupGainedUser, act.class
    assert_equal @group.id, act.group.id

    # users own activity should always show up:
    act = Activity::UserJoinedGroup.for_all(ruth).last
    assert_equal @group.id, act.group.id
  end

  ##
  ## Remove the user
  ##
  def test_destroy_membership
    @group.remove_user!(@blue)
    Tracking::Action.track :destroy_membership, group: @group, user: @blue

    act = Activity::GroupLostUser.for_all(@red).last
    assert_activity_for_user_group(act, @blue, @group)

    act = Activity::GroupLostUser.for_group(@group, @red).last
    assert_activity_for_user_group(act, @blue, @group)

    act = Activity::UserLeftGroup.for_all(@blue).last
    assert_activity_for_user_group(act, @blue, @group)
  end

  def test_deleted_subject
    @blue.add_contact!(@red, :friend)
    Tracking::Action.track :create_friendship, user: @blue, other_user: @red
    act = Activity::Friend.for_me(@blue).last
    former_name = @red.name
    @red.destroy

    assert act.reload, 'there should still be a friend activity'
    assert_nil act.other_user
    assert_equal former_name, act.other_user_name
    assert_equal "<user>#{former_name}</user>",
                 act.user_span(:other_user)
  end

  def test_avatar
    new_group = FactoryGirl.create(:group)

    @blue.add_contact!(@red, :friend)
    Tracking::Action.track :create_friendship, user: @blue, other_user: @red
    @blue.send_message_to!(@red, 'hi @red')
    new_group.add_user!(@blue)
    Tracking::Action.track :create_membership, group: new_group, user: @blue

    friend_act = Activity::Friend.find_by_subject_id(@blue.id)
    user_joined_act = Activity::UserJoinedGroup.find_by_subject_id(@blue.id)
    gained_act = Activity::GroupGainedUser.find_by_subject_id(new_group.id)
    post_act = Activity::MessageSent.find_by_subject_id(@red.id)
    # we do not create PrivatePost Activities anymore
    assert_nil post_act

    # the person doing the thing should be the avatar for it
    # disregarding whatever is the subject (in the gramatical/language
    # sense) of the activity
    assert_equal @blue, friend_act.avatar
    assert_equal @blue, user_joined_act.avatar
    assert_equal @blue, gained_act.avatar
    # assert_equal @blue, post_act.avatar
  end

  def test_associations
    assert check_associations(Activity)
  end

  def assert_activity_for_user_group(act, user, group)
    assert_equal group.id, act.group.id
    assert_equal user.id, act.user.id
    assert_in_description(act, group)
    assert_in_description(act, user)
    assert_not_nil act.icon
  end

  def assert_in_description(act, thing)
    assert_match thing.name, act.description
  end
end
