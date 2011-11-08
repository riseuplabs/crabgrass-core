class Wikis::VersionsController < Wikis::BaseController

  before_filter :fetch_version, :only => [:show, :destroy, :revert]
  before_filter :login_required

  permissions 'wikis/versions'

  def show
  end

  def index
  end

  def destroy
    # TODO
    # @version.destroy
    # redirect_to wiki_path(@wiki)
  end

  def revert
    # TODO
    ## we still lack this in the model:
    ## @wiki.revert_to(version, current_user)
    ## old_way (TM):
    # @wiki.revert_to_version(version.version, current_user)
    # @wiki.unlock! :document, current_user, :break => true
    # redirect_to wiki_path(@wiki)
  end

  protected

  def fetch_version
    @version = @wiki.find_version(params[:id])
  rescue Wiki::VersionNotFoundException => ex
    flash.now[:error] =  ex.message
    return false
  end

end


