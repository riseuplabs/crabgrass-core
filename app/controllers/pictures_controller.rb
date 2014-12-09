#
# This controller is only called for private pictures or public pictures
# that have not yet been cached publicly.
#
# For now, all pictures are public.
#

class PicturesController < ApplicationController

  before_filter :fetch_picture

  #
  # for now, all pictures are public.
  #
  def show
    if Rails.env == 'development'
      # allow generation of a new geometry, for testing purposes only
      @picture.render!(@geometry)
    else
      # prevent generation of a new geometry
      @picture.render(@geometry)
    end
    send_file(@picture.private_file_path(@geometry), type: @picture.content_type, disposition: 'inline')
  end

  protected

  def fetch_picture
    id = params[:id1] + params[:id2]
    @picture  = Picture.find id.to_i
    @geometry = Picture::Geometry[params[:geometry]]
  end

end

