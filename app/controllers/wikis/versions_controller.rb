class Wikis::VersionsController < Wikis::BaseController

  def show
    unless @version = @wiki.versions.find_by_version(params[:id])
      flash.now :version_doesnt_exist.t
    end
  end

  def index
  end

end


