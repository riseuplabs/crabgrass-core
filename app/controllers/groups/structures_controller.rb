class Groups::StructuresController < Groups::SettingsController

  guard :may_edit_group_structure?, actions: [:new, :create, :destroy]

  def show
  end

  def new
    @committee = group_class.new
  end

  def create
    if group_type == :committee
      raise_denied unless may_create_committee?
    else
      raise_denied unless may_create_council?
    end
    @committee = group_class.create group_params
    @group.add_committee!(@committee)
    @committee.add_user!(current_user) if @committee.council?
    Activity.track :group_created, group: @committee, user: current_user
    success :group_successfully_created.t
    redirect_to group_url(@committee)
  end

  protected

  def group_type
    case params[:type]
      when 'committee' then :committee
      when 'council' then :council
      else raise 'error'
    end
  end
  helper_method :group_type

  def group_class
    case group_type
      when :council then Council
      when :committee then Committee
      else raise 'error'
    end
  end

  def group_params
    params.fetch(:group, {}).permit :name, :full_name, :language
  end
end
