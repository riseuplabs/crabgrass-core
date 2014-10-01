class RankedVotePossiblesController < Pages::BaseController
  before_filter :fetch_poll
  permissions 'ranked_vote_page'

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
end
