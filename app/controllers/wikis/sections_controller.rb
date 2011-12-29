class Wikis::SectionsController < Wikis::BaseController

  stylesheet 'wiki_edit'
  javascript :wiki, :action => :edit

  permissions 'wikis'

  guard :edit => :may_edit_wiki?,
        :update => :may_edit_wiki?

  before_filter :login_required, :get_section_markup

  def edit
    # remove other peoples lock if it exists
    @wiki.unlock! @section, current_user,
      :break => params[:break_lock],
      :with_structure => true
    @wiki.lock!(@section, current_user)
  rescue Wiki::SectionLockedError => exc
    render :template => 'wikis/sections/locked', :locals => {:err => exc}
  end

  def update
    @old_section = @section
    if params[:cancel]
      @wiki.unlock(@section, current_user ) if @wiki
    else
      @successor = @wiki.successor_for_section(@section)
      @section = @wiki.update_section! @section, current_user,
        params[:wiki][:version], params[:wiki][:body]
      success
    end

  rescue Wiki::VersionExistsError, Wiki::SectionLockedOnSaveError => exc
    warning exc
    @markup = params[:wiki][:body]
    @wiki.version = @wiki.versions.last.version + 1
    # this won't unlock if they don't hit save:
    @wiki.unlock! :document, current_user,
      :break => true,
      :with_structure => true
    render :template => '/wikis/sections/edit'
  end


protected

  def get_section_markup
    @section = params[:id]
    @markup = @wiki.get_body_for_section(@section)
  end

  ### FILTERS
#  def prepare_wiki_body_html
#    if current_locked_section and current_locked_section != :document
#      @wiki.body_html = body_html_with_form(current_locked_section)
#    end
#  end

end
