class DiscussionPageController < Page::BaseController
  def show
    authorize @page
  end

  def print
    authorize @page, :show?
    render layout: 'printer_friendly'
  end

  protected

  def setup_view; end
end
