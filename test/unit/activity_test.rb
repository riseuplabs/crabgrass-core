require File.dirname(__FILE__) + '/../test_helper'

class ActivityTest < ActiveSupport::TestCase

  def setup
    @joe = User.make
    @ann = User.make
    @group = Group.make
    @group.add_user! @joe
    @group.add_user! @ann
    @joe.reload
    @ann.reload
  end

  def test_contact
    @joe.add_contact!(@ann, :friend)

    act = FriendActivity.for_all(@joe).find(:first)
    assert act, 'there should be a friend activity created'
    assert_equal @joe, act.user
    assert_equal @ann, act.other_user
  end

  def test_user_destroyed

    assert @joe.peer_of?(@ann)
    username = @ann.name
    @ann.destroy

    act = UserDestroyedActivity.for_all(@joe).find(:first)
    assert act, 'there should be a user destroyed activity created'
    assert_equal username, act.username
  end

  def test_group_destroyed
    groupname = @group.name
    @group.destroy_by(@joe)

    acts = Activity.for_all(@joe).find(:all)
    act = acts.detect{|a|a.class == GroupDestroyedActivity}
    assert_equal groupname, act.groupname
    assert_in_description(act, @group)
  end

  def test_group_created
    group = Group.create!(:name => "plants",
                          :fullname =>"All the plants") do |group|
      group.avatar = Avatar.new
      group.created_by = @ann
    end
    act = GroupCreatedActivity.find(:last)
    assert_activity_for_user_group(act, @ann, group)

    act = UserCreatedGroupActivity.find(:last)
    assert_activity_for_user_group(act, @ann, group)
    assert_equal group.id, act.group.id
    assert_equal @ann.id, act.user.id
    assert_in_description(act, group)
    assert_in_description(act, @ann)
  end

  def test_membership
    ruth = User.make
    @group.add_user!(ruth)

    assert_nil UserJoinedGroupActivity.for_all(@ann).find_by_subject_id(ruth.id),
      "The new peers don't get UserJoinedGroupActivities."

    act = GroupGainedUserActivity.for_all(@ann).last
    assert_equal @group.id, act.group.id,
      "New peers should get GroupGainedUserActivities."

    act = GroupGainedUserActivity.for_group(@group, ruth).last
    assert_equal GroupGainedUserActivity, act.class
    assert_equal @group.id, act.group.id

    # users own activity should always show up:
    act = UserJoinedGroupActivity.for_all(ruth).last
    assert_equal @group.id, act.group.id

    ##
    ## Remove the user
    ##

    @group.remove_user!(ruth)

    act = GroupLostUserActivity.for_all(@ann).last
    assert_activity_for_user_group(act, ruth, @group)

    act = GroupLostUserActivity.for_group(@group, @ann).last
    assert_activity_for_user_group(act, ruth, @group)

    act = UserLeftGroupActivity.for_all(ruth).last
    assert_activity_for_user_group(act, ruth, @group)
  end

  def test_deleted_subject
    @joe.add_contact!(@ann, :friend)
    act = FriendActivity.for_all(@joe).find(:first)
    former_name = @ann.name
    @ann.destroy

    assert act, 'there should be a friend activity created'
    assert_equal nil, act.other_user
    assert_equal former_name, act.other_user_name
    assert_equal "<span class=\"user\">#{former_name}</span>",
      act.user_span(:other_user)
  end

  def test_avatar
    new_group = Group.make

    @joe.add_contact!(@ann, :friend)
    @joe.send_message_to!(@ann, "hi @ann")
    new_group.add_user!(@joe)

    friend_act = FriendActivity.find_by_subject_id(@joe.id)
    user_joined_act = UserJoinedGroupActivity.find_by_subject_id(@joe.id)
    group_gained_act = GroupGainedUserActivity.find_by_subject_id(new_group.id)
    post_act = PrivatePostActivity.find_by_subject_id(@ann.id)
    # we do not create PrivatePostActivities anymore
    assert_nil post_act


    # the person doing the thing should be the avatar for it
    # disregarding whatever is the subject (in the gramatical/language sense) of the activity
    assert_equal @joe, friend_act.avatar
    assert_equal @joe, user_joined_act.avatar
    assert_equal @joe, group_gained_act.avatar
    #assert_equal @joe, post_act.avatar
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

