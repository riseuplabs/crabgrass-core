class Groups::BaseController < ApplicationController

  before_filter :fetch_group
  permissions 'groups'
  helper 'groups/links'

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

  ##
  ## PATHS
  ##

  # sometimes it is nice to rely on the way rails will guess resource
  # routes based on the class. so, we alias some of the group routes to be
  # also supported by networks, councils, and committees.
  def self.path_alias(path_method)
    path_method = path_method.to_s
    for type in ['network', 'committee', 'council']
      new_method = path_method.sub(/^group/, type)
      alias_method new_method, path_method
      helper_method new_method
    end
  end

  path_alias :group_avatars_path
  path_alias :group_avatar_path

  def new_group_committee_path(group)
    new_group_structure_path(group, :type => 'committee')
  end
  helper_method :new_group_committee_path

  def new_group_council_path(group)
    new_group_structure_path(group, :type => 'council')
  end
  helper_method :new_group_council_path

end

