#
# Routes:
#
#  update:  page_attributes_path      /pages/:page_id/attributes
#

class Pages::AttributesController < Pages::SidebarsController

  before_filter :login_required

  guard :update => :may_admin_page?

  def update
    if params[:public]
      @page.public = params[:public]
      @page.updated_by = current_user
      @page.save!
      render(:update) {|page| page.replace 'public_li', publish_checkbox}
    elsif params[:owner]
      if params[:owner] == current_user.name
        owner = current_user
      else
        owner = Group.find_by_name params[:owner]
      end
      raise_not_found('owner') unless owner
      @page.owner = owner
      @page.save!
      redirect_to page_path(@page)
      success
    end
  end

end

