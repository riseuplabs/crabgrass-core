class Wikis::AssetsController < Wikis::BaseController

  permissions 'wikis/assets'

  before_filter :fetch_assets, :only => :new
  before_filter :login_required

  def new
  end

  # response goes to an iframe, so requires responds_to_parent
  def create
    asset = Asset.build :uploaded_data => params[:asset][:uploaded_data]
    @page ||= asset.create_page(current_user, @context.entity)
    asset.save
    fetch_assets # now the new one should be included
    responds_to_parent do
      render
    end
  end

  protected

  def fetch_assets
    @images = Asset.visible_to(current_user, @group || @page.group).
      media_type(:image).
      most_recent.
      paginate(pagination_params(:per_page => 8))
  end

end
