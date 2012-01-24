class Wikis::VersionsController < Wikis::BaseController

  before_filter :fetch_version, :only => [:show, :destroy, :revert]
  before_filter :login_required

  permissions 'wikis/versions'

  def show
    unless request.xhr?
      params[:page] = @wiki.page_for_version(@version)
      @versions = @wiki.versions.most_recent.paginate(pagination_params)
    end
  end

  def index
    flash.keep
    @versions = @wiki.versions.most_recent.paginate(pagination_params)
    @version = @versions.first
  end

  def destroy
    @version.destroy
    if @version.destroyed?
      success :wiki_version_destroy_success.t
    else # last version
      warning :wiki_version_destroy_failed.t
    end
    redirect_to wiki_versions_path(@wiki)
  end

  def revert
    @wiki.revert_to_version(@version, current_user)
    redirect_to wiki_versions_path(@wiki)
  end

  protected

  def fetch_version
    @version = @wiki.find_version(params[:id])
  rescue Wiki::VersionNotFoundError => ex
    error ex
    return false
  end

end


