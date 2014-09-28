##
## Avatars are the little icons used for users and groups.
##
## This controller is in charge of showing them. See me/avatars or groups/avatars
## for editing them.
##

class AvatarsController < ApplicationController

  # always enable cache, even in dev mode.
  def self.perform_caching; true; end
  def perform_caching; true; end
  caches_page :show

  def show
    @image = Avatar.find_by_id params[:id]
    if @image.nil?
      size = Avatar.pixels(params[:size])
      size.sub!(/^\d*x/,'')
      filename = "#{File.dirname(__FILE__)}/../../public/images/default/#{size}.jpg"
      send_data(IO.read(filename), type: 'image/jpeg', disposition: 'inline')
    else
      content_type = 'image/jpeg'
      data = @image.resize(params[:size], content_type);
      response.headers['Cache-Control'] = 'public, max-age=86400'
      send_data data, type: content_type, disposition: 'inline'
    end
  end

end
