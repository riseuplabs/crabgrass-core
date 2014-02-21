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
    task(:init_group_permissions => :environment) do
      Group.all.each do |group|
        group.send(:create_permissions)
      end
    end

    desc "Create keys to the groups based on their old profile settings; for use once in upgrading data to cg 1.0"
    task(:migrate_group_permissions => :environment) do
      Group.all.each(&:migrate_permissions!)
    end

    desc "Creates keys to the user based on settings found in their old profile; also for use once upgrading data to cg 1.0"
    task :user_permissions => :environment do
      User.all.each(&:migrate_permissions!)
    end

    desc "Set created_at timestamps where it is not set"
    task :init_created_at => :environment do
      [Membership, Tagging, Task, Profile].each do |model|
        puts "- #{model.name}"
        oldest = model.order(:created_at).where("created_at IS NOT NULL").first
        older = oldest.created_at - 1.week
        model.update_all({ :created_at => older }, "#{model.quoted_table_name}.created_at IS NULL")
      end
    end

  end
end


