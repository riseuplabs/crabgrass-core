module Tracking::Action

  EVENT_CREATES_ACTIVITIES = {
    create_group: ['Activity::GroupCreated', 'Activity::UserCreatedGroup'],
    create_membership: ['Activity::GroupGainedUser', 'Activity::UserJoinedGroup'],
    destroy_membership: ['Activity::GroupLostUser', 'Activity::UserLeftGroup'],
    request_to_destroy_group: ['Activity::UserProposedToDestroyGroup'],
    create_friendship: ['Activity::Friend'],
    create_post: ['Page::History::AddComment'],
    update_post: ['Page::History::UpdateComment'],
    destroy_post: ['Page::History::DestroyComment'],
    update_page: ['Page::History::Update'],
    create_page: ['Page::History::PageCreated'],
    destroy_page: [],
    delete_page: ['Page::History::Deleted'],
    undelete_page: [],
    update_participation: ['Page::History::UpdateParticipation'],
    update_group_access: ['Page::History::GrantGroupAccess'],
    update_user_access: ['Page::History::GrantUserAccess'],
    update_title: ['Page::History::ChangeTitle'],
    update_wiki: ['Page::History::UpdatedContent'],
    create_star: ['Notice::PostStarredNotice']
  }

  def self.track(event, options = {})
    # Activities have keys to link the different activities for the same event
    options[:key] ||= rand(Time.now.to_i)
    EVENT_CREATES_ACTIVITIES[event].each do |class_name|
      klass = class_name.constantize
      klass = klass.pick_class(options) if klass.respond_to? :pick_class
      next if klass.blank?
      activity = klass.create! filter_options_for_class(klass, options)
    end
  end

  protected

  def self.filter_options_for_class(klass, options)
    options.select do |k,v|
      klass.attribute_method?("#{k}=") ||
        klass.method_defined?("#{k}=")
    end
  end
end
