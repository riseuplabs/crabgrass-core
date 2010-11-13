class Me::AvatarsController < Me::BaseController

  def new
    @avatar = Avatar.new
    render :action => 'edit'
  end

  def create
    raise ErrorMessage.new('already exists') if current_user.avatar
    current_user.avatar = Avatar.create!(params[:avatar])
    current_user.save!
  ensure
    redirect_to me_settings_url
  end

  def edit
    @avatar = current_user.avatar
  end

  def update
    expire_avatar(current_user.avatar)
    current_user.avatar.update_attributes! params[:avatar]
    current_user.save! # ensure new updated_at. not sure why?
  ensure
    redirect_to me_settings_url
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

