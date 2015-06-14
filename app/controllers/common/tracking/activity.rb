# We have lists of former actions in a number of places. For example page
# history lists actions related to a given page.
# We want to list activities of groups and users on their landing pages and on
# a combined feed for the current_users friends and groups.
#
# Therefore we need to keep track of the things people do. We store them in
# different records based on the context (Activity and PageHistory).
#
# This module makes creating the records from the controller easy.
#
# If you follow the conventions all you need to do is add a after_filter for
# the actions you want to track:
#
# class Groups::GroupsController < ...
#   track_actions :create, :destroy
# ...
#
# This will have the same effect as an after filter for track_action:
#   after_filter :track_action, only: [:create, :destroy]
#
# track_action will call Action.track(:create_group, options). It will include
# the following default arguments if the corresponding variables are set:
#   group: @group,
#   user: @user || current_user,
#   page: @page,
#   current_user: current_user
#
# Please make sure that Action.track can deal with the event symbol you
# hand it. It has a lookup table for the records to create for a
# given symbol.
#
# If you want to customize the arguments you can overwrite track_action.
# The options given will overwrite the defaults.
#
# class Groups::StructuresController < ...
#   :track_actions :create, :destroy
#   ...
#   def track_action
#     super("#{action}_group", group: @committee)
#   end

module Common::Tracking::Action

  def self.track_actions(*actions)
    options = actions.extract_options!
    after_filter :track_action, options.merge(only: actions)
  end

  def track_action(event = nil, options = {})
    event, options = nil, event if options.nil? && event.is_a?(Hash)
    event ||= "#{action_string}_#{controller_name}"
    event_options = options.reverse_merge current_user: current_user,
      group: @group,
      user: @user || current_user,
      page: @page
    Tracking::Action.track event.to_sym, event_options
  end

end
