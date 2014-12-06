#
# controllers including this must have a before_filter setup()
# which must set @entity and @success_url
#

module Common::Avatars

  ##
  ## ACTIONS
  ##

  def new
    @avatar = Avatar.new
    render template: 'common/avatars/edit'
  end

  def create
    raise ErrorMessage.new('already exists') if @entity.avatar
    @entity.avatar = Avatar.create!(avatar_params)
    @entity.save!
  ensure
    redirect_to @success_url
  end

  def edit
    @avatar = @entity.avatar
    render template: 'common/avatars/edit'
  end

  def update
    expire_avatar(@entity.avatar)
    @entity.avatar.update_attributes! avatar_params
    @entity.increment!(:version)
  ensure
    redirect_to @success_url
  end

  protected

  def avatar_params
    params[:avatar].permit(:image_file, :image_file_url)
  end

  def expire_avatar(avatar)
    if avatar
      for size in Avatar::SIZES.keys
        expire_page controller: '/avatars', action: 'show', id: avatar.id, size: size
      end
    end
  end

end

