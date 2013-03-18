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

    desc "Creates keys to the user's profile based on settings found in their old profile; also for use once upgrading data to cg 1.0"
    task :user_permissions => :environment do

      def log(user, holder, flag)
        print "%25s %7s %20s? -> " % ['['+user.login+']', holder, flag]
      end

      def log_result(result)
        puts (result ? "YES" : "NO")
      end

      User.all.each do |user|

        ## get holders
        public_holder = CastleGates::Holder[:public]
        friends_holder = CastleGates::Holder[user.associated(:friends)]
        peers_holder = CastleGates::Holder[user.associated(:peers)]

        [ :view, :see_groups, :see_contacts, :pester, :request_contact ].each do |gate_name|
          gate = user.gate(gate_name)

          ## all gates correspond to may_* flags in the profile (except for :view -> may_see)
          profile_flag = (gate_name == :view ? "may_see" : "may_#{gate_name}")

          ## check public profile setting for this gate...
          log(user, 'PUBLIC', profile_flag)
          if user.profiles.public.send(profile_flag)
            log_result true
            ## ... then grant access to PUBLIC
            user.grant_access!(public_holder => gate.name)

          else
            log_result false
          end

          log(user, 'FRIENDS', profile_flag)
          ## check private profile settings...
          if user.profiles.private.send(profile_flag)
            log_result true

            ## ... then grant access to FRIENDS
            user.grant_access!(friends_holder => gate.name)

            log(user, 'PEERS', profile_flag)
            ## ... grant access to PEERS as well, when 'peer' flag is set.
            if user.profiles.private.peer?
              log_result true

              user.grant_access!(peers_holder => gate.name)

            else
              log_result false
            end
          else
            log_result false
            log(user, 'PEERS', profile_flag)
            log_result false
          end

        end # gates
      end # users
    end # user_permissions task

  end
end


