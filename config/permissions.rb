#
# There are two types of permission in Crabgrass:
#
#   (1) model permissions
#       low level permissions, stored in db, defined in this file.
#
#   (2) controller/view permissions
#       higher level permissions, based on methods, built on model permissions,
#       and defined in /app/permissions
#
# Entity permissions
# -------------------------------
#
# These permissions are common to both users and groups.
#
#   view    -- show the profile 'home' page for the entity.
#   pester  -- send an entity notifications, typically about pages.
#   burden  -- share with an entity a page
#   spy     -- track activity of the entity, like join grp or when logged in
#   comment -- post a comment to the entity's public message board
#

class Permissions < CastleGates::Permissions

  holder 0, :public,
    :label => :public,
    :info => :public_description

  holder_alias :public, :model => UnauthenticatedUser

  ##
  ## USER
  ##

  castle User do

    # entity gates
    gate 1, :view,
      :default_open => :friend_of_user,
      :label => :may_view_label,
      :info => :may_view_description

    gate 2, :pester,
      :default_open => :user,
      :label => :may_pester_label,
      :info => :may_pester_description

    gate 3, :burden,          :default_open => [:friend_of_user, :peer_of_user]
    gate 4, :spy
    gate 5, :comment,         :default_open => [:friend_of_user, :peer_of_user]

    # user gates
    gate 6, :see_contacts,
      :default_open => :friend_of_user,
      :label => :may_see_contacts_label,
      :info => :may_see_contacts_description

    gate 7, :see_groups,
      :default_open => :friend_of_user,
      :label => :may_see_groups_label,
      :info => :may_see_groups_description

    gate 8, :request_contact,
      :default_open => :user,
      :label => :may_request_contact_label,
      :info => :may_request_contact_description


    protected

    #
    # Setting public for anything also sets peer and friend access.
    #
    def after_grant_access(holder, gate)
      if holder == :public
        grant_access! self.associated(:friends) => gate
        grant_access! self.associated(:peers) => gate
      end
    end

    #
    # Removing peer or friend access automatically removes public.
    #
    def after_revoke_access(holder, gate)
      if holder == self.associated(:friends) || holder == self.associated(:peers)
        revoke_access! :public => gate
      end
    end

  end

  holder 1, :user, :model => User do
    def holder_codes
      codes = [:public]
      if !new_record?
        codes << {:holder => :group, :ids => self.all_group_id_cache}
        codes << {:holder => :friend_of_user, :ids => self.friend_id_cache}
        codes << {:holder => :peer_of_user, :ids => self.peer_id_cache}
      end
      codes
    end
  end

  holder 7, :friend_of_user,
    :label => :friends,
    :info => :friends_description,
    :association => User.associated(:friends) do
    def friend_of_user?(user)
      friend_of?(user)
    end
  end

  holder 9, :peer_of_user,
    :label => :peers,
    :info => :peers_description,
    :association => User.associated(:peers) do
    def peer_of_user?(user)
      peer_of?(user)
    end
  end

  ##
  ## GROUP
  ##

  castle Group do
    # entity gates
    gate 1, :view,    :default_open => :public
    gate 2, :pester
    gate 3, :burden
    gate 4, :spy
    gate 5, :comment

    # group gates
    gate 6,  :edit
    gate 7,  :admin
    gate 8,  :see_members
    gate 9,  :see_committees
    gate 10, :see_networks
    gate 11, :request_membership, :default_open => :user
    gate 12, :join

    protected

    def create_permissions
      grant_access! self => :all
      if council?
        # councils steal admin rights
        parent.revoke_access! parent => :admin
        parent.grant_access! self => :all
      elsif committee?
        # committees are always admin'ed by parent group
        revoke_access! self => :admin
        grant_access! parent => :all
      end
    end

    def destroy_permissions
      if council?
        parent.grant_access! parent => :admin
      end
    end

    #
    # Removing peer or friend access automatically removes public.
    #
    def after_revoke_access(holder, gate)
      if holder == :public
        if gate == :view
          revoke_access! :public => [:see_members, :see_committees, :see_networks, :request_membership]
        elsif gate == :request_membership
          revoke_access! :public => :join
        end
      end
    end

  end

  holder 8, :group, :model => Group
  holder_alias :group, :model => Committee
  holder_alias :group, :model => Council
  holder_alias :group, :model => Network

end