class Groups::StructuresController < Groups::SettingsController

  guard :show => :may_show_group_structure?,
        :new => :may_edit_group_structure?,
        :create => :may_edit_group_structure?,
        :destroy => :may_edit_group_structure?

  def show
  end

  def new
    if group_type == :committee
      @committee = Committee.new
    elsif group_type == :council
      @council = Council.new
    end
  end

  #
  # not very DRY, but we need properly named @var for the create form to work.
  #
  def create
    if group_type == :committee
      raise_denied unless may_create_committee?
      @committee = Committee.new params[:committee].merge(:created_by => current_user)
      @committee.save!
      @group.add_committee!(@committee)
      redirect_to group_url(@committee)
    elsif group_type == :council
      raise_denied unless may_create_council?
      @council = Council.new params[:council].merge(:created_by => current_user)
      @council.save!
      @group.add_committee!(@council)
      redirect_to group_url(@council)
    end
    success
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

end
