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
  holder 0, :public,
         label: :public,
         info: :public_description

  holder_alias :public, model: User::Unknown

  ##
  ## USER
  ##

  castle User do
    # entity gates
    gate 1, :view,
         default_open: :friend_of_user,
         label: :may_view_label,
         info: :may_view_description

    gate 2, :pester,
         default_open: :user,
         label: :may_pester_label,
         info: :may_pester_description

    gate 3, :burden, default_open: %i[friend_of_user peer_of_user]
    gate 4, :spy
    gate 5, :comment, default_open: %i[friend_of_user peer_of_user]

    # user gates
    gate 6, :see_contacts,
         default_open: :friend_of_user,
         label: :may_see_contacts_label,
         info: :may_see_contacts_description

    gate 7, :see_groups,
         default_open: :friend_of_user,
         label: :may_see_groups_label,
         info: :may_see_groups_description

    gate 8, :request_contact,
         default_open: :user,
         label: :may_request_contact_label,
         info: :may_request_contact_description

    protected

    #
    # Setup the default permissions
    #
    after_create :create_permissions
    def create_permissions
      grant_access! friends: %i[view pester burden comment see_contacts see_groups request_contact]
      grant_access! peers: %i[pester burden comment request_contact]
      grant_access! public: %i[pester request_contact]
    end

    #
    # Setting public for anything also sets peer and friend access.
    #
    def after_grant_access(holder, gates)
      if holder == :public
        grant_access! associated(:friends) => gates
        grant_access! associated(:peers) => gates
      end
    end

    #
    # Removing peer or friend access automatically removes public.
    #
    def after_revoke_access(holder, gates)
      if holder == associated(:friends) || holder == associated(:peers)
        revoke_access! public: gates
      end
    end
  end

  holder 1, :user, model: User do
    def holder_codes
      codes = [:public]
      unless new_record?
        codes << { holder: :group, ids: all_group_id_cache }
        codes << { holder: :friend_of_user, ids: friend_id_cache }
        codes << { holder: :peer_of_user, ids: peer_id_cache }
      end
      codes
    end
  end

  holder 7, :friend_of_user,
         label: :friends,
         info: :friends_description,
         association: User.associated(:friends) do
    def friend_of_user?(user)
      friend_of?(user)
    end
  end

  holder 9, :peer_of_user,
         label: :peers,
         info: :peers_description,
         association: User.associated(:peers) do
    def peer_of_user?(user)
      peer_of?(user)
    end
  end

  ##
  ## GROUP
  ##

  castle Group do
    # entity gates
    gate 1, :view
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
    gate 11, :request_membership
    gate 12, :join

    protected

    def create_permissions
      grant_access! self => :all
      if council? && parent
        # councils steal admin rights
        parent.revoke_access! parent => :admin
        parent.grant_access! self => :all
      elsif committee?
        # committees are always admin'ed by parent group
        revoke_access! self => :admin
        grant_access! parent => :all if parent
      end
    end

    def destroy_permissions
      parent.grant_access! parent => :admin if council?
    end

    #
    # Removing peer or friend access automatically removes public.
    #
    def after_revoke_access(holder, gates)
      if holder == :public
        if gates.include?(:view)
          revoke_access! public: %i[see_members see_committees see_networks request_membership]
        end
        revoke_access! public: :join if gates.include?(:request_membership)
      end
    end
  end

  holder 8, :group, model: Group
  holder_alias :group, model: Group::Committee
  holder_alias :group, model: Group::Council
  holder_alias :group, model: Group::Network
end
