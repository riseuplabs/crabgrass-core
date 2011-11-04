class Wikis::VersionsController < Wikis::BaseController

  before_filter :fetch_version, :only => [:show, :destroy, :revert]

  permissions 'wikis/versions', 'wiki'

  def show
  end

  def index
  end

  def destroy
    # @version.destroy
    # redirect_to wiki_path(@wiki)
  end

  def revert
    ## we still lack this in the model:
    ## @wiki.revert_to(version, current_user)
    ## old_way (TM):
    # @wiki.revert_to_version(version.version, current_user)
    # @wiki.unlock! :document, current_user, :break => true
    # redirect_to wiki_path(@wiki)
  end

  protected

  def fetch_version
    unless @version = @wiki.versions.find_by_version(params[:id])
      flash.now :version_doesnt_exist.t
      return false
    end
  end

end


