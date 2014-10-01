class RankedVotePageController < Pages::BaseController
  before_filter :fetch_poll
  before_filter :find_possibles, only: [:show, :edit]
  permissions 'ranked_vote_page'

  def show
    # we need to specify the whole page_url not just the action here
    # because we might have ended up here from the DispatchController.
    redirect_to(page_url(@page, action: 'edit')) unless @poll.possibles.any?

    @who_voted_for = @poll.tally
    @sorted_possibles = @poll.ranked_candidates.collect { |id| @poll.possibles.find(id)}
  end

  def edit
  end

  # ajax only, returns nothing
  # for this to work, there must be a <ul id='sort_list_xxx'> element
  # and it must be declared sortable like this:
  # <%= sortable_element 'sort_list_xxx', .... %>
  def sort
    if params[:sort_list_voted].empty?
      render nothing: true
      return
    else
      @poll.votes.by_user(current_user).delete_all
      ids = params[:sort_list_voted]
      ids.each_with_index do |id, rank|
        next unless id.to_i != 0
        possible = @poll.possibles.find(id)
        @poll.votes.create! user: current_user, value: rank, possible: possible
      end
      find_possibles
    end
  end

  def print
    @who_voted_for = @poll.tally
    @sorted_possibles = @poll.ranked_candidates.collect { |id| @poll.possibles.find(id)}

    render layout: "printer-friendly"
  end

  protected

  def fetch_poll
    @poll = @page.data if @page
    true
  end

  def find_possibles
    @possibles_voted = []
    @possibles_unvoted = []

    @poll.possibles.each do |pos|
      if pos.votes.by_user(current_user).first
        @possibles_voted << pos
      else
        @possibles_unvoted << pos
      end
    end

    @possibles_voted = @possibles_voted.sort_by { |pos| pos.votes.by_user(current_user).first.try.value || -1 }
  end

  def setup_options
    # @options.show_print = true
    @options.show_tabs = true
  end

end

