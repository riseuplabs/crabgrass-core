class Groups::GroupsController < Groups::BaseController

  before_filter :login_required, :force_type

  def new
    @group = Group.new
  end

  def create
    @group = Group.new params[:group]
    @group.save!
    if @group.valid?
      redirect_to group_url(@group)
      success
    end
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


