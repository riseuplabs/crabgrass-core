class DiscussionPageController < Pages::BaseController

  def show
  end

  def print
    render layout: "printer-friendly"
  end

  protected

  def setup_view
  end

end
