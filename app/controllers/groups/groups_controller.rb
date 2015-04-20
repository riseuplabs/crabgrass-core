class Groups::GroupsController < Groups::BaseController

  # restricting the before filter to { :only => :destroy } doesn't work, because
  # then it changes position in the filter chain and runs after the guards, but
  # may_admin_group? requires @group to be set.
  def fetch_group() super if action? :destroy end
  protected :fetch_group

  before_filter :force_type,  only: ['new', 'create']
  before_filter :initialize_group,  only: ['new', 'create']
  before_filter :fetch_member_group, only: 'create'

  guard :may_ALIAS_group?

  def new
  end

  #
  # responsible for creating groups and networks.
  # councils and committees are created by groups/structures
  #
  def create
    @group.save!
    success :group_successfully_created.t
    redirect_to group_url(@group)
  end

  #
  # immediately destroy a group.
  # for destruction that requires approval, see RequestToDestroyOurGroup.
  # unlike creation, all destruction of all group types is handled here.
  #
  def destroy
    parent = @group.parent
    @group.destroy_by(current_user)
    success :thing_destroyed.t(thing: @group.name)
    # TODO: write a wrapper for mailer that does the iteration
    group.users_before_destroy.each do |recipient|
      Mailer.group_destroyed_notification(recipient, group, mailer_options).deliver
    end
    if parent
      redirect_to group_url(parent)
    else
      redirect_to me_url
    end
  end

  protected

  def group_type
    if %w/group network council committee/.include? params[:type].to_s
      params[:type].to_sym
    else
      :group
    end
  end
  helper_method :group_type

  def group_class
    case group_type
      when :group then Group
      when :network then Network
      when :committee then Committee
      when :council then Council
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
    @group = group_class.new group_params
    @group.created_by = current_user
    # setting @network will make the form correctly report errors for networks
    @network = @group
  end

  def fetch_member_group
    if @group.network? and @group.initial_member_group
      raise_denied unless current_user.may?(:admin, @group.initial_member_group)
    end
  end

  def group_params
    permitted = [:name, :full_name, :language]
    permitted << :initial_member_group if group_type == :network
    params.fetch(group_type, {}).permit *permitted
  end
end
