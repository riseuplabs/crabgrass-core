class RateManyPageController < Pages::BaseController
  before_filter :fetch_poll

  guard :may_edit_page?
  guard show: :may_show_page?

  def show
    @possibles = @poll ? @poll.possibles.sort_by{|p| p.position||0 } : []
  end

  # ajax only, returns nothing
  # for this to work, there must be a <ul id='sort_list_xxx'> element
  # and it must be declared sortable like this:
  # <%= sortable_element 'sort_list_xxx', .... %>
  def sort
    return unless params[:sort_list].present?
    ids = params[:sort_list]
    @poll.possibles.each do |possible|
      position = ids.index( possible.id.to_s )
      possible.update_attribute('position',position+1) if position
    end
    render nothing: true
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
