#
# This will grant a group's access to its members.
# This is for the migration to core's castle_gates permission system to work
# with data created before this system was added.
#
# If we wanted to migrate group (or user) profile settings, we could do that here.
#
# Instead, currently, all groups (and users) will be set to most restrictive permission settings.
#
# This task should only need to be run once. However, running it again shouldn't hurt.
#
#

namespace :cg do
  namespace :upgrade do
    desc "Gives groups self access; for use once in upgrading data to cg 1.0"
    task(:group_permissions => :environment) do
      Group.all.each do |group|
        group.send(:create_permissions)
      end
    end
  end
end


