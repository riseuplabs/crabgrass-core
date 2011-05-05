# 
# Routes:
#
#  update:  page_attributes_path      /pages/:page_id/attributes
#

class Pages::AttributesController < Pages::SidebarController

  before_filter :login_required

  def update
    if params[:public]
      @page.public = params[:public]
      @page.updated_by = current_user
      @page.save!
      render(:update) {|page| page.replace 'public_li', public_line}
    elsif params[:owner]
      group = Group.find_by_name params[:owner]
      raise_not_found unless group
      @page.owner = group
      @page.save!
      redirect_to page_path(@page)
      success
    end
  end

end

