class Wiki::AssetsController < Wiki::BaseController
  before_filter :fetch_assets, only: :new

  def new
    # FIXME: Authorize needed because BaseController wants us to
    # authorize each action. Authorize asset creation instead. Authorize
    # asset creation instead
    authorize @wiki, :show?
  end

  def create
    # FIXME: Authorize asset creation instead
    authorize @wiki, :show?
    asset = Asset.build uploaded_data: params[:asset][:uploaded_data], parent_page: @page
    @page ||= asset.create_page(current_user, @wiki.context)
    asset.save
    fetch_assets # now the new one should be included
  end

  protected

  def fetch_assets
    @images = Asset.visible_to(current_user, @wiki.context)
                   .media_type(:image)
                   .most_recent
                   .paginate(pagination_params(per_page: 3))
  end
end
