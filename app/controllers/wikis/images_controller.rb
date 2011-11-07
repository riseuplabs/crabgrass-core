class Wiki::ImagesController < Wiki::BaseController

  before_filter :fetch_images

  def new
  end

  # response goes to an iframe, so requires responds_to_parent
  def create
    asset = Asset.build params[:asset]
    @page ||= asset.create_page
    asset.save
    responds_to_parent do
      render
    end
  end

  protected

  def fetch_images
    @images = Asset.visible_to(current_user, @group || @page.group).
      media_type(:image).
      most_recent.
      # with_url. #TODO: make sure images have url set.
      all(:limit=>20)
  end

end
