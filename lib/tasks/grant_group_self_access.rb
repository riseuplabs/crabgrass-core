#
# This will grant a group's access to its members. 
# This is for the migration to core's lock/key permission system to work 
# with data created before this system was added.
#
# If we wanted to migrate group (or user) profile settings, we could do that here. 
# Instead, we cannot do so, and all groups (and users) will be set to most restrictive permission settings.
#
# This task should only need to be run once. However, running it again shouldn't hurt.
#
#

namespace :cg do
  desc "Gives groups self access; for use once in upgrading data to core."
  task(:grant_group_self_access => :environment) do
    Group.all.each do |group|

      group.grant! group, :all

      # if group is a council, only that council-group, not the parent-group,
      # should have admin access over the parent-group
      if group.council? && group.parent #seem to be come cases where a council doesn't have a parent group.
        group.parent.grant! group, :all 
        group.parent.revoke! group.parent, :admin
      end

      #saving not necessary, right?

    end

  end
end


