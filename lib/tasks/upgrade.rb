#  UPGRADE TASKS
#
# Some data structures have changed over years. These tasks help upgrade them.
#
# They only need to be run once and only when migrating from older versions.
# However, when adding tasks make sure running them again won't hurt.
#
# The tasks themselves are sorted by the crabgrass version that introduced
# them. You will find them in the upgrade subdirectory.
#

namespace :cg do
  namespace :upgrade do
    desc "Complete upgrade to crabgrass 0.6"
    task :to_0_6 => [
      'db:migrate',
      'cg:cleanup:remove_committees_without_parent',
      'cg:upgrade:init_group_permissions',
      'cg:upgrade:migrate_group_permissions',
      'cg:upgrade:user_permissions',
      'cg:upgrade:secure_password',
      'cg:upgrade:init_created_at',
      'cg:upgrade:convert_message_pages',
      'cg:upgrade:owner_id_in_page_terms',
      'ts:index'
    ]

    desc "Upgrade from 0.6.0 to crabgrass 0.6.2"
    task :to_0_6_2 => [
      'db:migrate',
      'cg:upgrade:migrate_ratings_to_stars',
      'cg:upgrade:reset_star_counters'
    ]
  end
end
