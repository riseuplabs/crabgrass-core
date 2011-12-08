class Wikis::DiffsController < Wikis::BaseController

  permissions 'wiki'

  helper 'wikis/versions'
  javascript :wiki

  before_filter :fetch_versions

  def show
    @diff = Crabgrass::Wiki::HTMLDiff.diff(@old.body_html, @new.body_html)
  rescue Wiki::VersionNotFoundException => err
    render :text => err.message
  end

  protected

  def fetch_versions
    old_id, new_id = params[:id].split('-')
    @old = @wiki.find_version(old_id)
    @new = @wiki.find_version(new_id)
    pagination = { :per_page => VERSIONS_PER_PAGE,
      :page => @wiki.page_for_version(@new, VERSIONS_PER_PAGE)
    }
    @versions = @wiki.versions.most_recent.paginate(pagination)
  end

end
