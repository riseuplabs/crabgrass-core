class Groups::GroupsController < Groups::BaseController

  before_filter :force_type,  :only => ['new', 'create']
  before_filter :fetch_group, :only => 'destroy'
  before_filter :login_required

  guard :new     => :may_create_group?,
        :create  => :may_create_group?,
        :destroy => :may_destroy_group?

  def new
    @group = Group.new
  end

  #
  # responsible for creating groups and networks.
  # councils and committees are created by groups/councils and
  # groups/committees, for permissions reasons.
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

  def destroy
  end

  protected

  def group_type
    case params[:type]
      when 'group' then :group
      when 'network' then :network
      when 'committee' then :committee
      when 'council' then :council
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


