class Group::BaseController < ApplicationController
  before_filter :fetch_group

  # default permission for all group controllers
  before_filter :login_required
  permissions :groups
  after_action :verify_authorized

  helper 'group/links'

  protected

  def fetch_group
    # group might be preloaded by DispatchController
    @group ||= Group.find_by_name(params[:group_id] || params[:id])
    raise_not_found unless policy(@group).show?
  end

  def setup_context
    @context = Context.find(@group) if @group and !@group.new_record?
    super
  end

  def new_group_committee_path(group)
    new_group_structure_path(group, type: 'committee')
  end
  helper_method :new_group_committee_path

  def new_group_council_path(group)
    new_group_structure_path(group, type: 'council')
  end
  helper_method :new_group_council_path
end
