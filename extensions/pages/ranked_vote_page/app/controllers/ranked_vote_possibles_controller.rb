class RankedVotePossiblesController < Pages::BaseController
  before_filter :fetch_poll
  before_filter :fetch_possible, only: [:edit, :update, :destroy]

  guard :may_edit_page?

  # returns nothing
  # for this to work, there must be a <ul id='sort_list_xxx'> element
  # and it must be declared sortable like this:
  # <%= sortable_element 'sort_list_xxx', .... %>
  def sort
    @poll.vote(current_user, sort_params)
    current_user.updated(@page)
    find_possibles
  rescue ActionController::ParameterMissing
    render nothing: true
  end

  def create
    @possible = @poll.possibles.create possible_params
    if @poll.valid? and @possible.valid?
      @page.unresolve
      current_user.updated(@page)
    else
      @poll.possibles.delete(@possible)
      warning @possible unless @possible.valid?
      warning @poll unless @poll.valid?
    end
  end

  def edit
  end

  def update
    @possible.update_attributes possible_params.permit(:description)
    current_user.updated(@page)
  end

  def destroy
    @possible.destroy
    current_user.updated(@page)
    render nothing: true
  end

  protected

  def possible_params
    params.require(:possible).permit(:name, :description)
  end

  def sort_params
    params.permit(:sort_list_voted => []).require :sort_list_voted
  end

  def fetch_poll
    @poll = @page.data if @page
    true
  end

  def fetch_possible
    @possible = @poll.possibles.find(params[:id])
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
