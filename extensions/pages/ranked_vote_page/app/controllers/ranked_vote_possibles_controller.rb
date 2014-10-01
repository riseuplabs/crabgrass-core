class RankedVotePossiblesController < Pages::BaseController
  before_filter :fetch_poll
  permissions 'ranked_vote_page'

  # returns nothing
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

  def create
    @possible = @poll.possibles.create params[:possible]
    if @poll.valid? and @possible.valid?
      @page.unresolve
    else
      @poll.possibles.delete(@possible)
      flash_message_now object: @possible unless @possible.valid?
      flash_message_now object: @poll unless @poll.valid?
    end
  end

  def update
    @possible = @poll.possibles.find(params[:id])
    params[:possible].delete('name')
    @possible.update_attributes(params[:possible])
  end

  def edit
    @possible = @poll.possibles.find(params[:id])
  end

  def destroy_
    possible = @poll.possibles.find(params[:id])
    possible.destroy
    render nothing: true
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

end
