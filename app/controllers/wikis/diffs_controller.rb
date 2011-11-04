class Wikis::DiffsController < Wikis::BaseController

  permissions 'wiki'

  def show
    old_id, new_id = params[:id].split('-')
    @old = @wiki.find_version(old_id)
    @new = @wiki.find_version(new_id)
    @diff = Crabgrass::Wiki::HTMLDiff.diff(@old.body_html, @new.body_html)
  rescue Wiki::VersionNotFoundException => err
    render :text => err.message
  end

end
