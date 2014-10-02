#
# We have shortcut urls to users and all kinds of groups. These are nice but we need to
# destinguish between the two different Controllers used for groups and people somewhere.
# DispatchController to the rescue.
#
# This Controller handles routes of the form /:context_id
# :context_id can be a group name or user login
# It will try to find the corresponding group or user and load their controller.
#

class ContextsController < DispatchController

  protected

  def find_controller
    context = params[:context_id]

    if context
      if context =~ /\ /
        # we are dealing with a committee!
        context.sub!(' ','+')
      end
      @group = Group.find_by_name(context)
      @user  = User.find_by_login(context) unless @group
    end
    return controller_for_group(@group) if @group
    return controller_for_people if @user
    raise ActiveRecord::RecordNotFound.new
  end

  def controller_for_group(group)
    params[:group_id] = params[:context_id]
    new_controller 'groups/home'

    #
    # we used to have different controllers for groups and networks.
    # we might again someday.
    #
    #if group.instance_of? Network
    #  if current_site.network and current_site.network == group
    #    new_controller 'site_network'
    #  else
    #    new_controller 'groups/networks'
    #  end
    #else
    #  new_controller 'groups/home'
    #end
  end

  def controller_for_people
    params[:person_id] = params[:context_id]
    new_controller 'people/home'
  end
end
