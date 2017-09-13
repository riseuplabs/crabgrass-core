class RankedVotePageController < Page::BaseController
  before_filter :fetch_poll
  before_filter :find_possibles, only: %i[show edit]

  def show
    # we need to specify the whole page_url not just the action here
    # because we might have ended up here from the DispatchController.
    redirect_to page_url(@page, action: :edit) unless @poll.possibles.any?

    @who_voted_for = @poll.tally
    @sorted_possibles = @poll.ranked_candidates.collect { |id| @poll.possibles.find(id) }
  end

  def edit; end

  def print
    @who_voted_for = @poll.tally
    @sorted_possibles = @poll.ranked_candidates.collect { |id| @poll.possibles.find(id) }

    render layout: 'printer-friendly'
  end

  protected

  def fetch_poll
    @poll = @page.data if @page
    true
  end

  def setup_options
    # @options.show_print = true
    @options.show_tabs = logged_in?
  end

  def find_possibles
    @possibles_voted = []
    @possibles_unvoted = []

    if logged_in?
      @poll.possibles.each do |pos|
        if pos.votes.by_user(current_user).first
          @possibles_voted << pos
        else
          @possibles_unvoted << pos
        end
      end
    end

    @possibles_voted = @possibles_voted.sort_by { |pos| pos.votes.by_user(current_user).first.try.value || -1 }
  end
end
