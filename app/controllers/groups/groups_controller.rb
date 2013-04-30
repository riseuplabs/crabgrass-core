class Groups::GroupsController < Groups::BaseController

  before_filter :fetch_group, :only => 'destroy'
  before_filter :force_type,  :only => ['new', 'create']
  before_filter :initialize_group,  :only => ['new', 'create']
  before_filter :fetch_member_group, :only => 'create'

  guard :may_ALIAS_group?

  def new
  end

  #
  # responsible for creating groups and networks.
  # councils and committees are created by groups/structures
  #
  def create
    @group.save!
    @group.add_group!(@member_group) if @member_group
    success :group_successfully_created.t
    redirect_to group_url(@group)
  end

  #
  # immediately destroy a group.
  # for destruction that requires approval, see RequestToDestroyOurGroup.
  # unlike creation, this all destruction of all group types is handled here.
  #
  def destroy
    parent = @group.parent
    @group.destroy_by(current_user)
    success :thing_destroyed.t(:thing => @group.name)
    if parent
      redirect_to group_url(parent)
    else
      redirect_to me_url
    end
  end

  protected

  def group_type
    case params[:type]
      when 'group' then :group
      when 'network' then :network
      when 'council' then :council
      when 'committee' then :committee
      else :group
    end
  end
  helper_method :group_type

  def group_class
    case group_type
      when :group then Group
      when :network then Network
      else raise 'error'
    end
  end

  #
  # if some non-normal groups are disabled, then
  # we force type 'group'
  #
  def force_type
    if !Conf.committees and !Conf.networks and !Conf.councils
      params[:type] = 'group'
    end
  end

  def initialize_group
    group_params = params[group_type] || {}
    @group = group_class.new group_params
    @group.created_by = current_user
    # setting @network will make the form correctly report errors for networks
    @network = @group
  end

  def fetch_member_group
    if @group.network? and params[:member_group_name].present?
      @member_group = Group.find_by_name(params[:member_group_name])
      raise_denied unless current_user.may?(:admin, @member_group)
      if @member_group.is_a? Network
        error(:networks_may_not_join_networks.t)
        render :new
      elsif @member_group.parent.is_a? Network
        error(:network_committees_may_not_join_networks.t)
        render :new
      end
    end
  end


end


