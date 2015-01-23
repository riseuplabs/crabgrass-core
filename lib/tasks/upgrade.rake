#  UPGRADE TASKS
#
# Some data structures have changed over years. These tasks help upgrade them.
#
# They only need to be run once and only when migrating from older versions. 
# However, when adding tasks make sure running them again won't hurt.
#
#
#

namespace :cg do
  namespace :upgrade do
    # This will grant a group's access to its members.
    # This is for the migration to core's castle_gates permission system to work
    # with data created before this system was added.
    #
    # If we wanted to migrate group (or user) profile settings, we could do that here.
    #
    # Instead, currently, all groups (and users) will be set to most restrictive permission settings.
    #
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
      [Membership, ActsAsTaggableOn::Tagging, Task, Profile].each do |model|
        puts "- #{model.name}"
        oldest = model.order(:created_at).where("created_at IS NOT NULL").first
        older = oldest.created_at - 1.week
        model.update_all({ :created_at => older }, "#{model.quoted_table_name}.created_at IS NULL")
      end
    end

    desc "Convert the MessagePages to other classes"
    task :convert_message_pages => :environment do

      require_relative 'upgrade/message_page'
      # first we turn all the Message Pages with more or less than
      # two participants into Discussion Pages.

      puts "#{MessagePage.count} Message pages."
      to_convert = MessagePage.connection.execute <<-EOSQL
      SELECT pages.id FROM pages
        JOIN user_participations AS parts ON parts.page_id = pages.id
        WHERE pages.type = "MessagePage"
        GROUP BY pages.id HAVING count(pages.id) <> 2
      EOSQL
      convert_ids = to_convert.to_a.flatten
      puts "Converting #{convert_ids.count} to DiscussionPages."
      MessagePage.where(id: convert_ids).update_all type: "DiscussionPage"

      pages = MessagePage.all
      puts "#{pages.count} Message pages left."
      puts "Converting to Messages."
      pages.each do |page|
        page.convert
      end
    end
    
  end
end


