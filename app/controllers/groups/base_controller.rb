class Groups::BaseController < ApplicationController

  before_filter :fetch_group
  permissions 'groups'
  helper 'groups/links'
  # default permission for all group controllers
  before_filter :login_required
  guard :may_admin_group?

  protected

  def fetch_group
    # group might be preloaded by DispatchController
    @group ||= Group.find_by_name(params[:group_id] || params[:id])
    @base ||= @group.becomes(Group)
  end

  def setup_context
    if @group and !@group.new_record?
      @context = Context.find(@group)
    end
    super
  end

  def new_group_committee_path(group)
    new_group_structure_path(group, :type => 'committee')
  end
  helper_method :new_group_committee_path

  def new_group_council_path(group)
    new_group_structure_path(group, :type => 'council')
  end
  helper_method :new_group_council_path

end

