class Page::HistoryController < Page::SidebarsController
  before_action :login_required

  def show
    authorize @page, :update?
  end
end
