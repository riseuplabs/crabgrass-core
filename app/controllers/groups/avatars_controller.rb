class Groups::AvatarsController < Groups::BaseController

  def new
    @avatar = Avatar.new
    render :action => 'edit'
  end

  def create
    raise ErrorMessage.new('already exists') if @group.avatar
    @group.avatar = Avatar.create!(params[:avatar])
    @group.save!
  ensure
    redirect_to group_settings_url(@group)
  end

  def edit
    @avatar = @group.avatar
  end

  def update
    expire_avatar(@group.avatar)
    @group.avatar.update_attributes! params[:avatar]
    @group.save! # ensure new updated_at. not sure why?
  ensure
    redirect_to group_settings_url(@group)
  end

  protected
 
  def expire_avatar(avatar)
    if avatar
      for size in Avatar::SIZES.keys
        expire_page :controller => 'avatars', :action => 'show', :id => avatar.id, :size => size
      end
    end
  end

end

