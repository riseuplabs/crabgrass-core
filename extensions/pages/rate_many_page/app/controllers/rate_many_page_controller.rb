class RateManyPageController < Page::BaseController
  before_filter :fetch_poll

  def show
    @possibles = @poll ? @poll.possibles.sort_by { |p| p.position || 0 } : []
  end

  def print
    @possibles = @poll.possibles.sort_by { |p| p.position || 0 }
    render layout: 'printer-friendly'
  end

  protected

  def fetch_poll
    authorize @page, :show?
    return true unless @page
    @poll = @page.data
  end
end
