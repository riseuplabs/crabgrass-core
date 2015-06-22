module Tracking::Action

  EVENT_CREATES_ACTIVITIES = {
    create_group: ['GroupCreatedActivity', 'UserCreatedGroupActivity'],
    create_membership: ['GroupGainedUserActivity', 'UserJoinedGroupActivity'],
    destroy_membership: ['GroupLostUserActivity', 'UserLeftGroupActivity'],
    request_to_destroy_group: ['UserProposedToDestroyGroupActivity'],
    create_friendship: ['FriendActivity'],
    create_post: ['PageHistory::AddComment'],
    update_post: ['PageHistory::UpdateComment'],
    destroy_post: ['PageHistory::DestroyComment'],
    update_page: ['PageHistory::Update'],
    create_page: ['PageHistory::PageCreated'],
    destroy_page: [],
    delete_page: ['PageHistory::Deleted'],
    undelete_page: [],
    update_participation: ['PageHistory::UpdateParticipation'],
    update_group_access: ['PageHistory::GrantGroupAccess'],
    update_user_access: ['PageHistory::GrantUserAccess'],
    update_title: ['PageHistory::ChangeTitle']
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
