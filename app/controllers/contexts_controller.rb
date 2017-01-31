#
# We have shortcut urls to users and all kinds of groups. These are nice but we need to
# destinguish between the two different Controllers used for groups and people somewhere.
# DispatchController to the rescue.
#
# This Controller handles routes of the form /:id
# :id can be a group name or user login
# It will try to find the corresponding group or user and load their controller.
#

class ContextsController < DispatchController

  protected

  def find_controller
    name = params[:id]
    controller_for_group(name)
  rescue ActiveRecord::RecordNotFound
    controller_for_person(name)
  end

  def controller_for_group(name)
    # we are dealing with a committee!
    name.sub!(' ','+') if name =~ /\ /

    @group = Group.where(name: name).first!
    params[:group_id] = params[:id]
    new_controller 'group/home'
  end

  def controller_for_person(login)
    @user = User.where(login: login).first!
    params[:person_id] = params[:id]
    new_controller 'person/home'
  end
end
