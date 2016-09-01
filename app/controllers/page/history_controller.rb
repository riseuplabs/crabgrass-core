class Page::HistoryController < Page::SidebarsController

  before_filter :login_required

  guard show: :may_edit_page?

  def show
  end

end

