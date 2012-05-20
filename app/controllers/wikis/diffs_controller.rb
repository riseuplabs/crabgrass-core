class Wikis::DiffsController < Wikis::BaseController

  permissions 'wikis/versions'

  guard :show => :may_show_wiki_diff?

  helper 'wikis/versions'
  javascript :wiki

  before_filter :fetch_versions

  def show
    if @old
      @diff = Crabgrass::Wiki::HTMLDiff.diff(@old.body_html, @new.body_html)
    else
      render :template => '/wikis/versions/show'
    end
  end

  protected

  def fetch_versions
    if params[:page]
      fetch_versions_with_page
    else
      fetch_versions_without_page
    end
  rescue Wiki::VersionNotFoundError => err
    error err
    redirect_to wiki_versions_path(@wiki)
  end

  def fetch_versions_without_page
    old_id, new_id = params[:id].split('-')
    @old = @wiki.find_version(old_id) unless old_id.blank?
    @version = @new = @wiki.find_version(new_id)
    params[:page] = @wiki.page_for_version(@new)
    @versions = @wiki.versions.most_recent.paginate(pagination_params)
  end

  def fetch_versions_with_page
    @versions = @wiki.versions.most_recent.paginate(pagination_params)
    @version = @new = @versions[0]
    @old = @versions[1]
  end
end
