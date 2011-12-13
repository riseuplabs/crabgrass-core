class Wikis::DiffsController < Wikis::BaseController

  permissions 'wikis/versions'

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
      fetch_versions_with_pagination
    else
      fetch_versions_without_pagination
    end
  rescue Wiki::VersionNotFoundError => err
    error err
    redirect_to wiki_versions_path(@wiki)
  end

  def fetch_versions_without_pagination
    old_id, new_id = params[:id].split('-')
    @old = @wiki.find_version(old_id) unless old_id.blank?
    @version = @new = @wiki.find_version(new_id)
    pagination = { :per_page => VERSIONS_PER_PAGE,
      :page => @wiki.page_for_version(@new, VERSIONS_PER_PAGE)
    }
    @versions = @wiki.versions.most_recent.paginate(pagination)
  end

  def fetch_versions_with_pagination
    pagination = pagination_params :per_page => VERSIONS_PER_PAGE
    @versions = @wiki.versions.most_recent.paginate(pagination)
    @version = @new = @versions[0]
    @old = @versions[1]
  end
end
