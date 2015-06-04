# We want to list activities of groups and users on their landing pages and on
# a combined feed for the current_users friends and groups.
#
# Therefore we need to keep track of the things people do. We store them in
# Activity records.
#
# This module makes creating the activity records from the controller easy.
#
# If you follow the conventions all you need to do is add a after_filter for
# the actions you want to track:
#
# class Groups::GroupsController < ...
#   after_filter :track_activity, only: [:create, :destroy]
# ...
#
# This will call Activity.track(:create_group, options). It will include the
# following options:
#   group: @group,
#   user: @user,
#   page: @page,
#   current_user: current_user
#
# Please make sure that Activity.track can deal with the event symbol you
# hand it. It has a lookup table for the activity records to create for a
# given symbol.
#
# If you want to customize the arguments you can overwrite track_activity.
# The options given will overwrite the defaults.
#
# class Groups::StructuresController < ...
#   after_filter :track_activity, only: [:create, :destroy]
#   ...
#   def track_activity
#     super("#{action}_group", group: @committee)
#   end

module Common::Application::ActivityTracking

  def track_activity(event = nil, options = {})
    event ||= "#{action_string}_#{controller_name}"
    event_options = options.reverse_merge current_user: current_user,
      group: @group,
      user: @user,
      page: @page
    Activity.track event.to_sym, event_options
  end

end
