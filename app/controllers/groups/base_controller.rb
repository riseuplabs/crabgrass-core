class Groups::BaseController < ApplicationController

  before_filter :fetch_group
  permissions 'groups/base', 'groups/memberships', 'groups/requests', 'groups/profiles', 'groups/settings', 'groups/home'
  helper 'groups/links'

  protected

  def fetch_group
    # group might be preloaded by DispatchController
    @group ||= Group.find_by_name(params[:group_id] || params[:id])
  end

  def setup_context
    if @group and !@group.new_record?
      Context.find(@group)
    end
  end

end

