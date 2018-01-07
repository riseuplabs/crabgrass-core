class Page::HistoryController < Page::SidebarsController
  before_filter :login_required

  def show
    authorize @page, :edit?
  end
end
