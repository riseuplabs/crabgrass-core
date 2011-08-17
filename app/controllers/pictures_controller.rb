#
# This controller is only called for private Picture objects.
#
# For now, all pictures are public, so this is just a stub.
#

class PicturesController < ApplicationController

  before_filter :fetch_picture

  #
  # for now, all pictures are public.
  #
  def show
    @picture.render!(@geometry)
    send_file(@picture.private_file_path(@geometry), :type => @picture.content_type, :disposition => 'inline')
  end

  protected

  def fetch_picture
    id = params[:id1] + params[:id2]
    @picture  = Picture.find id.to_i
    @geometry = @picture.to_geometry params[:geometry]
  end

end

