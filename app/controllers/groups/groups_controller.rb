class Groups::GroupsController < Groups::BaseController

  # restricting the before filter to { :only => :destroy } doesn't work, because
  # then it changes position in the filter chain and runs after the guards, but
  # may_admin_group? requires @group to be set.
  def fetch_group() super if action? :destroy end
  protected :fetch_group

  before_filter :initialize_group,  only: ['new', 'create']

  guard :may_ALIAS_group?

  def new
  end

  #
  # responsible for creating groups and networks.
  # councils and committees are created by groups/structures
  #
  def create
    @group.save!
    current_user.reload # may have gained access to new group
    @group.add_user!(current_user) unless @group.network? && may_admin_group?
    success :group_successfully_created.t
    redirect_to group_url(@group)
  end

  #
  # immediately destroy a group.
  # for destruction that requires approval, see RequestToDestroyOurGroup.
  # unlike creation, all destruction of all group types is handled here.
  #
  def destroy
    @group.destroy
    success :thing_destroyed.t(thing: @group.name)
    redirect_to group_destroyed_redirect
  end

  before_filter :fetch_associations, only: :destroy
  after_filter :create_activity, only: :destroy
  after_filter :notify_former_users, only: :destroy

  protected

  # load all associations we need after the group was destroyed
  def fetch_associations
    @group = Group.where(id: @group.id).includes(:users, :parent).first
  end

  def notify_former_users
    notification = Notification.new(:group_destroyed, group: @group, user: current_user)
    notification.deliver_mails_to(@group.users, mailer_options)
    notification.create_notices_for(@group.users)
  end

  def create_activity
    key = rand(Time.now.to_i)
    @group.users.each do |recipient|
      GroupDestroyedActivity.create! groupname: @group.name,
        recipient: recipient,
        destroyed_by: current_user,
        key: key
    end
  end

  def group_destroyed_redirect
    if @group.parent
      group_url(@group.parent)
    else
      me_url
    end
  end

  def group_type
    if Conf.networks && params[:type].to_s == 'network'
      :network
    else
      :group
    end
  end
  helper_method :group_type

  def group_class
    group_type.to_s.capitalize.constantize
  end

  def initialize_group
    @group = group_class.new group_params
    @group.created_by = current_user
    @group.initial_member_group = member_group if group_type == :network
  end

  def member_group
    name = params.fetch(:group, {})[:initial_member_group]
    Group.where(name: name).first.tap do |group|
      current_user.may!(:admin, group)
    end
  end

  def group_params
    params.fetch(:group, {}).permit :name, :full_name, :language
  end
end
