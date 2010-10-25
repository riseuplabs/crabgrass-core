##
## Avatars are the little icons used for users and groups.
##

class AvatarsController < ApplicationController

  def create
    unless params[:image]
      flash[:error] = "no image uploaded"
      #render(:nothing => true, :layout => true)
      return
    end
    group = Group.find params[:group_id] if params[:group_id]
    user  = User.find params[:user_id] if params[:user_id]
    thing = group || user
    if thing.avatar
      for size in %w(xsmall small medium large xlarge big)
        expire_page :controller => 'static', :action => 'avatar', :id => thing.avatar.id, :size => size
      end
      thing.avatar.image_file = params[:image][:image_file]
      thing.avatar.save!
    else
      avatar = Avatar.create(params[:image])
      thing.avatar = avatar
    end
    thing.save! # make sure thing.updated_at has been updated.
    flash_message :success => I18n.t(:avatar_image_upload_success)
  rescue Exception => exc
    flash_message :exception => exc
  ensure
    redirect_to params[:redirect]
  end

  caches_page :show

  def show
    @image = Avatar.find_by_id params[:id]
    if @image.nil?
      size = Avatar.pixels(params[:size])
      size.sub!(/^\d*x/,'')
      filename = "#{File.dirname(__FILE__)}/../../public/images/default/#{size}.jpg"
      send_data(IO.read(filename), :type => 'image/jpeg', :disposition => 'inline')
    else
      render :template => 'avatars/show.jpg.flexi'
    end
  end

end
