#
# CLEANUP tasks
#
# Removing data that has become invalid.
#
# In an ideal world these would not be necessary. If you run any of these and
# they actually do sth. you probably want to find out why and remove the cause.
#

namespace :cg do
  namespace :cleanup do
    desc "Run all cleanup tasks"
    task all: [
      :remove_groups_ending_in_plus,
      :remove_group_dups,
      :remove_user_dups,
      :remove_committees_without_parent,
#
# since there seem to be no meaningful committees without a parent on the
# production server we remove all of them rather than turning them into groups
#      :convert_committees_without_parent,
      :remove_dead_participations,
      :remove_dead_federatings,
      :remove_dead_memberships,
      :remove_empty_posts,
      :remove_dead_posts,
      :remove_dead_chat_channels,
      :remove_dead_chat_messages,
      :remove_unused_tags,
      :merge_duplicate_tags,
      :remove_duplicate_taggings,
      :clear_invalid_email_addresses,
      :remove_dangling_page_histories,
      :remove_dead_requests,
      :remove_invalid_federation_requests,
      :remove_invalid_email_requests,
      :remove_empty_tasks,
      :fix_activity_types,
      :fix_invalid_request_states,
      :reset_peer_caches,
      :fix_contributors_count
    ]

    # There are 6 of these on we.riseup.net from a certain timespan
    # looks like this was caused by a bug that is now fixed.
    desc "Remove groups with names ending in +"
    task(:remove_groups_ending_in_plus => :environment) do
      count = Group.where("name LIKE '%+'").delete_all
      puts "Removed #{count} groups that ended in '+'"
    end

    # This will leave invalid records behind such as GroupParticipations
    # and Memberships whose group does not exist anymore.
    # Rather than instantiating all the groups and calling the depended hooks
    # we clean them up afterwards in other rake tasks.
    desc "Remove duplicate groups"
    task(:remove_group_dups => :environment) do
      empty_dups = Group.joins("JOIN groups AS dup ON groups.name = dup.name").
        where("groups.id NOT IN (SELECT group_id FROM group_participations)")
      later = empty_dups.where("groups.id > dup.id").pluck(:id)
      count = Group.where(id: later).delete_all
      puts "Removed #{count} empty group duplicates that were created later"
      early = empty_dups.where("groups.id < dup.id").pluck(:id)
      count = Group.where(id: early).delete_all
      puts "Removed #{count} empty group duplicates that were created first"
      dups = Group.joins("JOIN groups AS dup ON groups.name = dup.name").
        where("groups.id > dup.id").pluck(:id)
      count = Group.where(id: dups).delete_all
      puts "#{count} group duplicates deleted that were not empty."
    end

    desc "Remove duplicate users that have no groups or pages"
    task(:remove_user_dups => :environment) do
      puts "Removing duplicate users. This may take some time."
      dups = User.joins("JOIN users AS dups ON dups.login = users.login").
        where('users.type IS NULL')   # no ghosts
      count = dups.where("users.id > dups.id").
        where("users.created_at = users.updated_at").
        select{|u| u.groups.empty?}.
        select{|u| u.pages.empty?}.
        each{|u| u.destroy}.count
      count += dups.where("users.id < dups.id").
        where("users.created_at = users.updated_at").
        select{|u| u.groups.empty?}.
        select{|u| u.pages.empty?}.
        each{|u| u.destroy}.count
      puts "Removed #{count} empty duplicated users."
      count = dups.where("users.id > dups.id").
        each{|u| u.destroy}.count
      puts "Removed #{count} duplicated users with pages and/or groups."
    end

    desc "Turn committees without a parent into normal groups"
    task(:convert_committees_without_parent => :environment) do
      count = Group::Committee.where(parent_id: nil).update_all(type: nil)
      puts "Turned #{count} committees without parent into groups"
    end

    desc "Remove committees without a parent into normal groups"
    task(:remove_committees_without_parent => :environment) do
      count = Group::Committee.where(parent_id: nil).delete_all
      puts "Deleted #{count} committees without parent"
    end

    desc "Remove all participations where the entity does not exist anymore"
    task(:remove_dead_participations => :environment) do
      count = User::Participation.where(dead_entity_sql('user')).delete_all
      count += User::Participation.where(dead_entity_sql('page')).delete_all
      puts "Removed #{count} User Participations."
      count = Group::Participation.where(dead_entity_sql('group')).delete_all
      count += Group::Participation.where(dead_entity_sql('page')).delete_all
      puts "Removed #{count} Group Participations."
    end

    desc "Remove all federatings where the group does not exist anymore"
    task(:remove_dead_federatings => :environment) do
      count = Group::Federating.where(dead_entity_sql('group')).delete_all
      puts "Removed #{count} Federatings with outdated groups."
      count = Group::Federating.where(dead_entity_sql('network', 'groups')).delete_all
      puts "Removed #{count} Federatings with outdated networks."
    end

    desc "Remove all federatings where the group does not exist anymore"
    task(:remove_dead_memberships => :environment) do
      count = Group::Membership.where(dead_entity_sql('group')).delete_all
      puts "Removed #{count} Memberships with outdated groups."
    end

    def dead_entity_sql(type, table = nil)
      table ||= type + 's';
      "(#{type}_id NOT IN (SELECT id FROM #{table})) OR (#{type}_id IS NULL)"
    end

    desc "Remove empty posts"
    task(:remove_empty_posts => :environment) do
      count = Post.where(body: nil).delete_all
      count += Post.where(body: '').delete_all
      puts "Removed #{count} empty posts"
    end

    desc "Remove posts of users that do not exist anymore"
    task(:remove_dead_posts => :environment) do
      count = Post.where(dead_entity_sql('user')).delete_all
      puts "Removed #{count} posts with a blank user"
    end

    desc "Remove Chat Channels of groups that do not exist anymore"
    task(:remove_dead_chat_channels => :environment) do
      count = ChatChannel.where(dead_entity_sql('group')).delete_all
      puts "Removed #{count} chat channels of former groups"
    end

    desc "Remove Chat Channel users of channels that do not exist anymore"
    task(:remove_dead_chat_channels => :environment) do
      count = ChatChannelsUser.where(dead_entity_sql('channel')).delete_all
      puts "Removed #{count} chat users of former channels"
    end

    desc "Remove Chat Messages of users that do not exist anymore"
    task(:remove_dead_chat_messages => :environment) do
      count = ChatMessage.where(dead_entity_sql('sender', 'users')).delete_all
      puts "Removed #{count} chat messages with a blank sender"
      count = ChatMessage.where(dead_entity_sql('channel')).delete_all
      puts "Removed #{count} chat messages without a channel"
    end

    desc "Remove dead taggings"
    task(:remove_dead_taggings => :environment) do
      count = ActsAsTaggableOn::Tagging.where(taggable_id: nil).delete_all
      puts "Deleted #{count} blank taggings."
    end

    desc "Remove unused tags"
    task(:remove_unused_tags => :environment) do
      count = ActsAsTaggableOn::Tag.
        where("id NOT IN (SELECT tag_id FROM taggings)").
        delete_all
      puts "Deleted #{count} unused tags."
    end

    desc "Merge duplicate tags"
    task(:merge_duplicate_tags => :environment) do
      map = ActsAsTaggableOn::Tag.
        joins("JOIN tags AS dup ON tags.name = dup.name").
        where("dup.id > tags.id")
      puts "Merging #{map.count} duplicate tags"
      count = 0
      map = map.select("dup.*, tags.id AS target")
      map.each do |dup|
        count += dup.taggings.update_all tag_id: dup.target
      end
      puts "Redirected #{count} taggings."
      Rake::Task["cg:cleanup:remove_unused_tags"].invoke
    end

    desc "Remove duplicate taggings"
    task(:remove_duplicate_taggings => :environment) do
      dup_join = <<-EOSQL
        JOIN taggings AS dups
          ON  dups.tag_id = taggings.tag_id
          AND dups.taggable_id = taggings.taggable_id
          AND dups.taggable_type = taggings.taggable_type
        EOSQL
      dups = ActsAsTaggableOn::Tagging.joins(dup_join).
        where("dups.id > taggings.id").pluck("dups.id")
      count = ActsAsTaggableOn::Tagging.where(id: dups).delete_all
      puts "Removed #{count} duplicate taggings"
    end

    desc "Clear all invalid email addresses"
    task(:clear_invalid_email_addresses => :environment) do
      invalid = User.where("email IS NOT NULL").select do |u|
        # validate_email_format returns errors - check if there are any
        ValidatesEmailFormatOf.validate_email_format(u.email).present?
      end
      count = User.where(id: invalid.map(&:id)).update_all(email: nil)
      puts "Cleared #{count} invalid email addresses." if count > 0
    end

    desc "Remove page histories where the page is gone"
    task(:remove_dangling_page_histories => :environment) do
      count = Page::History.where(dead_entity_sql('page')).delete_all
      puts "Removed #{count} page history records without a page"
      count = Page::History.where(dead_entity_sql('user')).delete_all
      puts "Removed #{count} page history records without a user"
    end

    desc "Remove requests for a group that is gone"
    task(:remove_dead_requests => :environment) do
      no_requestable_group = Request.
        where(requestable_type: 'Group').
        where("(requestable_id NOT IN (SELECT id FROM groups))")
      count = no_requestable_group.delete_all
      puts "Removed #{count} requests to groups that are gone."
    end

    desc "Remove invites to join a network with another network"
    task(:remove_invalid_federation_requests => :environment) do
      invalid = RequestToJoinOurNetwork.
        joins("JOIN groups ON groups.id = recipient_id").
        where(groups: {type: 'Network'}).
        where("state != 'approved'").
        pluck(:id)
      count = RequestToJoinOurNetwork.
        where(id: invalid).
        delete_all
      puts "Removed #{count} requests to join a network with another network."
    end

    desc "Remove email requests with invalid email"
    task(:remove_invalid_email_requests => :environment) do
      invalid = RequestToJoinUsViaEmail.
        where(state: 'pending').select("id, email").all.
        select{|r| ValidatesEmailFormatOf::validate_email_format(r.email)}.
        map(&:id)
      count = RequestToJoinUsViaEmail.
        where(id: invalid).
        delete_all
      puts "Removed #{count} requests via invalid email adresses."
    end

    desc "Remove tasks that have no name and no description"
    task(:remove_empty_tasks => :environment) do
      count = Task.where(name: '', description: '').delete_all
      puts "Removed #{count} tasks that lacked a name and a description"
    end

    desc "Fix type column in activities so the classes actually exist"
    task(:fix_activity_types => :environment) do
      count = Activity.where(type: 'UserRemovedFromGroupActivity').
        update_all(type: 'UserLeftGroupActivity')
      puts "Fixed #{count} Activities by setting an existing type."
    end

    desc "Fix invalid states of requests"
    task(:fix_invalid_request_states => :environment) do
      count = Request.where(state: 'ignored').
        update_all(state: 'pending')
      puts "Fixed #{count} Requests by setting a valid state."
    end

    desc "Reset peer caches so changes to the peer definition can have an effect"
    task(:reset_peer_caches => :environment) do
      count = User.update_all(peer_id_cache: nil)
      "Reset the peers for #{count} users."
    end

    desc "Fix contributors count for pages"
    task(:fix_contributors_count => :environment) do
      count = Page.update_all <<-EOSQL
        contributors_count = (
          SELECT COUNT(user_participations.id) FROM user_participations
          WHERE user_participations.page_id = pages.id
          AND user_participations.changed_at IS NOT NULL
        )
      EOSQL
    end
  end
end
