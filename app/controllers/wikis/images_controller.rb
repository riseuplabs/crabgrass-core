class Wikis::ImagesController < Wikis::BaseController

  permissions 'wikis/images'

  before_filter :fetch_images
  before_filter :login_required

  def new
  end

  # response goes to an iframe, so requires responds_to_parent
  def create
    asset = Asset.build :uploaded_data => params[:asset][:uploaded_data]
    @page ||= asset.create_page(current_user, @group)
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
