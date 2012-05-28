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

CastleGates.exception_class = PermissionDenied

CastleGates.define do

  holder 0, :public

  ##
  ## USER
  ##

  castle User do

    # entity gates
    gate 1, :view,            :default_open => :friend_of_user
    gate 2, :pester,          :default_open => :user
    gate 3, :burden,          :default_open => [:friend_of_user, :peer_of_user]
    gate 4, :spy
    gate 5, :comment,         :default_open => [:friend_of_user, :peer_of_user]

    # user gates
    gate 6, :see_contacts,    :default_open => :friend_of_user
    gate 7, :see_groups,      :default_open => :friend_of_user
    gate 8, :request_contact, :default_open => :user

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

  holder 7, :friend_of_user, :association => User.associated(:friends) do
    def friend_of_user?(user)
      friend_of?(user)
    end
  end

  holder 9, :peer_of_user, :association => User.associated(:peers) do
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
    gate 2, :pester,  :default_open => :member_of_group
    gate 3, :burden,  :default_open => :member_of_group
    gate 4, :spy,     :default_open => :member_of_group
    gate 5, :comment, :default_open => :member_of_group

    # group gates
    gate 6,  :edit
    gate 7,  :admin
    gate 8,  :see_members
    gate 9,  :see_committees
    gate 10, :see_networks
    gate 11, :request_membership, :default_open => :user
    gate 12, :join
  end

  holder 8, :group, :model => Group
  holder_alias :group, :model => Committee
  holder_alias :group, :model => Council
  holder_alias :group, :model => Network

  holder nil, :member_of_group, :association => Group.associated(:users) do
    def member_of_group?(user)
      user.member_of?(self)
    end
  end

end
