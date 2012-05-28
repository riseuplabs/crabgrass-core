class Groups::GroupsController < Groups::BaseController

  before_filter :force_type,  :only => ['new', 'create']
  before_filter :fetch_group, :only => 'destroy'

  guard :may_ALIAS_group?

  def new
    if group_type == :group
      @group = Group.new
    elsif group_type == :network
      @network = Network.new
    end
  end

  #
  # responsible for creating groups and networks.
  # councils and committees are created by groups/structures
  #
  def create
    @group = new_group_from_params
    @network = @group
    # ^^ what is this? setting @network will make the form correctly report errors for networks
    @group.save!
    if @group.network? and params[:member_group_name]
      member_group = Group.find_by_name(params[:member_group_name])
      @group.add_group!(member_group) if current_user.may?(:admin, member_group)
    end
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

  def new_group_from_params
    group_class.new params[group_type].merge(:created_by => current_user)
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

end


