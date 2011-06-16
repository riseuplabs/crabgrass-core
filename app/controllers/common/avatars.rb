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
    render :action => 'edit'
  end

  def create
    raise ErrorMessage.new('already exists') if @entity.avatar
    @entity.avatar = Avatar.create!(params[:avatar])
    @entity.save!
  ensure
    redirect_to @success_url
  end

  def edit
    @avatar = @entity.avatar
    render :template => 'common/avatars/edit'
  end

  def update
    expire_avatar(@entity.avatar)
    @entity.avatar.update_attributes! params[:avatar]
    @entity.save! # ensure new updated_at. not sure why?
  ensure
    redirect_to @success_url
  end

  protected

  def expire_avatar(avatar)
    if avatar
      for size in Avatar::SIZES.keys
        expire_page :controller => '/avatars', :action => 'show', :id => avatar.id, :size => size
      end
    end
  end

end

