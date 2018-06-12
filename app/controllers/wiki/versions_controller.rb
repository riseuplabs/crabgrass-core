class Wiki::VersionsController < Wiki::BaseController

  def show; end

  def index
    authorize @wiki, :update?
    @versions = @wiki.versions.try.most_recent.paginate(pagination_params)
  end

  protected

  # making sure the version is available for the permission
  def fetch_wiki
    super
    return if action? :index
    authorize @wiki, :update?
    @version = @wiki.find_version(params[:id])
    @former = @wiki.find_version(params[:id].to_i - 1) if params[:id].to_i > 1
  rescue Wiki::VersionNotFoundError => ex
    error ex
    redirect_to action: :index
  end
end
