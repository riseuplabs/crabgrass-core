class RateManyPossiblesController < Pages::BaseController
  before_filter :fetch_poll

  guard :may_edit_page?

  def create
    @possible = @poll.possibles.create params[:possible]
    if @poll.valid? and @possible.valid?
      @page.unresolve # update modified_at, auto_summary, and make page unresolved for other participants
    else
      @poll.possibles.delete(@possible)
      flash_message_now object: @possible unless @possible.valid?
      flash_message_now object: @poll unless @poll.valid?
      redirect_to page_url(@page, action: 'show')
    end
  end

  def destroy
    return unless @poll
    possible = @poll.possibles.find(params[:possible])
    possible.destroy

    current_user.updated @page # update modified date, and auto_summary, but do not make it unresolved

    redirect_to page_url(@page, action: 'show')
  end

  def update
    new_value = params[:value].to_i
    @possible = @poll.possibles.find(params[:id])
    @poll.votes.by_user(current_user).for_possible(@possible).delete_all
    @poll.votes.create! user: current_user, value: new_value, possible: @possible
    current_user.updated(@page, resolved: true)
  end

  protected

  def fetch_poll
    return true unless @page
    @poll = @page.data
  end

end
