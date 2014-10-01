class RateManyPageController < Pages::BaseController
  before_filter :fetch_poll

  guard :may_edit_page?
  guard show: :may_show_page?

  def show
    @possibles = @poll ? @poll.possibles.sort_by{|p| p.position||0 } : []
  end

  def print
  @possibles = @poll.possibles.sort_by{|p| p.position||0 }
    render layout: "printer-friendly"
  end

  protected

  def fetch_poll
    return true unless @page
    @poll = @page.data
  end

end
