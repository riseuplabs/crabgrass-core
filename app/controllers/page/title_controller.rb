class Page::TitleController < Page::SidebarsController

  guard :may_edit_page?
  track_actions :update


  # Return the edit title form. This is called by modalbox to load the popup contents.
  def edit
  end

  def update
    @old_name = @page.name
    @page.title   = params[:page][:title]
    @page.summary = params[:page][:summary]
    @page.name    = params[:page][:name].to_s.nameize if params[:page][:name].present?
    @page.updated_by = current_user
    @new_name = @page.name
    @page.save!
  end

end

