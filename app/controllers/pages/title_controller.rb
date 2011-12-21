#
# Routes:
#  edit_page_title_path  GET /pages/:page_id/title/edit  {:controller=>"pages/title", :action=>"edit"}
#  page_title_path       PUT /pages/:page_id/title       {:controller=>"pages/title", :action=>"update"}
#

class Pages::TitleController < Pages::SidebarsController

  permissions 'pages'
  before_filter :login_required

  # Return the edit title form. This is called by modalbox to load the popup contents.
  def edit
  end

  def update
    @old_name = @page.name
    @page.title   = params[:page][:title]
    @page.summary = params[:page][:summary]
    @page.name    = params[:page][:name].to_s.nameize if params[:page][:name].any?
    @page.updated_by = current_user
    @new_name = @page.name
    @page.save!
  end

  protected

end

