require_relative '../test_helper'

##
# Tests for migrate_permissions!, in order:
#
# * public  may :view ?
# * friends may :view ?
# * peers   may :view ?
# * public  may :see_contacts ?
# * friends may :see_contacts ?
#
# Assuming that the rest works as well then.
##

module Migration
  class UserPermissionTest < ActiveSupport::TestCase

    fixtures :users, :groups, :memberships

    def setup
      @user = FactoryGirl.create :user
    end

    def test_migrate_public_may_view
      @user.keys.destroy_all

      assert ! users(:blue).may?(:view, @user),
        'strangers cannot view a user without any keys set up'

      @user.profiles.public.update_attributes!(
        :may_see => true
      )

      @user.migrate_permissions!

      users(:blue).clear_access_cache
      assert users(:blue).may?(:view, @user),
        'strangers can view this user, after migrating permissions'
    end

    def test_migrate_friend_may_view
      # setup
      @user.add_contact!(users(:blue), :friend)
      groups(:animals).add_user!(@user)
      @user.revoke_access!(CastleGates::Holder[@user.associated(:friends)] => :view)

      # check assumptions after setup
      assert users(:blue).friend_of?(@user)
      assert users(:kangaroo).peer_of?(@user)
      assert ! users(:red).friend_of?(@user)
      assert ! users(:red).peer_of?(@user)

      assert ! users(:blue).may?(:view, @user),
        'friends cannot view this user'

      @user.profiles.public.update_attributes!(
        :may_see => false
      )
      @user.profiles.private.update_attributes!(
        :may_see => true,
        :peer => false
      )

      @user.migrate_permissions!

      users(:blue).clear_access_cache
      assert users(:blue).may?(:view, @user),
        'friends can view this user, after migrating permissions'
      assert ! users(:kangaroo).may?(:view, @user),
        'peers cannot view this user, after migrating permissions'
      assert ! users(:red).may?(:view, @user),
        'strangers cannot view this user, after migrating permissions'

    end

    def test_migrate_peer_may_view
      groups(:animals).add_user!(@user)
      @user.revoke_access!(CastleGates::Holder[@user.associated(:peers)] => :view)

      assert @user.member_of?(groups(:animals))
      assert @user.peer_of?(users(:kangaroo))

      assert ! users(:kangaroo).may?(:view, @user),
        'peers cannot view this user'

      @user.profiles.public.update_attributes!(
        :may_see => false
      )
      @user.profiles.private.update_attributes!(
        :may_see => true,
        :peer => true
      )

      @user.migrate_permissions!

      users(:kangaroo).clear_access_cache
      assert users(:kangaroo).may?(:view, @user),
        'peers can view this user after migration'
      assert ! users(:red).may?(:view, @user),
        'strangers cannot view this user after migration'
    end

    def test_migrate_public_may_see_contacts
      @user.keys.destroy_all

      assert ! users(:blue).may?(:see_contacts, @user),
        'strangers cannot see the contacts of a user without any keys set up'

      @user.profiles.public.update_attributes!(
        :may_see_contacts => true
      )

      @user.migrate_permissions!

      users(:blue).clear_access_cache
      assert users(:blue).may?(:see_contacts, @user),
        'strangers can see contacts of this user, after migrating permissions'
    end

    def test_migrate_friend_may_see_contacts
      # setup
      @user.add_contact!(users(:blue), :friend)
      @user.revoke_access!(CastleGates::Holder[@user.associated(:friends)] => :see_contacts)

      assert ! users(:blue).may?(:see_contacts, @user),
        'friends cannot see the contacts of this user'

      @user.profiles.public.update_attributes!(
        :may_see_contacts => false
      )
      @user.profiles.private.update_attributes!(
        :may_see_contacts => true,
        :peer => false
      )

      @user.migrate_permissions!

      users(:blue).clear_access_cache
      assert users(:blue).may?(:see_contacts, @user),
        'friends can see contacts of this user, after migrating permissions'
      assert ! users(:red).may?(:see_contacts, @user),
        'strangers cannot see contacts of this user, after migrating permissions'
    end


  end
end
