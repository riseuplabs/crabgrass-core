# 
# Routes:
#
#  index:   page_participations_path  /pages/:page_id/participations
#  create:  page_participations_path  /pages/:page_id/participations
#  new:     new_page_participation_path /pages/:page_id/participations/new
#  edit:    edit_page_participation_path /pages/:page_id/participations/:id/edit
#  update:  page_participation_path      /pages/:page_id/participations/:id
#  destroy: page_participation_path      /pages/:page_id/participations/:id
#

class Pages::ParticipationsController < Pages::SidebarController

  before_filter :login_required

  def update
    if params[:watch]
      @upart = @page.add(current_user, :watch => params[:watch])
      @upart.save!
      render(:update) {|page| page.replace 'watch_li', watch_line}
    elsif params[:star]
      @upart = @page.add(current_user, :star => params[:star])
      @upart.save!
      render(:update) {|page| page.replace 'star_li', star_line}
    end
  end

  def create
    update
  end

  protected

  def fetch_data
    @participation = UserParticipation.find(params[:id]) if params[:id]
  end

  def authorized?
    may_show_page?
  end

end

