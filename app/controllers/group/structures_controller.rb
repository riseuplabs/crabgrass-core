class Group::StructuresController < Group::SettingsController

  def show;
    authorize @group
  end

  def new
    authorize @group, :edit_structure?
    @committee = group_class.new
  end

  def create
    authorize @group, :edit_structure?
    if group_type == :committee
      raise PermissionDenied unless policy(@group).may_create_committee?
    else
      raise PermissionDenied unless policy(@group).may_create_council?
    end
    @committee = group_class.new group_params
    @group.add_committee!(@committee)
    @committee.add_user!(current_user) if @committee.council?
    success :group_successfully_created.t
    redirect_to group_url(@committee)
  end

  def destroy
    authorize @group, :edit_structure?
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
    when :council then Group::Council
    when :committee then Group::Committee
    else raise 'error'
    end
  end

  def group_params
    params.fetch(:group, {}).permit :name, :full_name, :language
  end

end
