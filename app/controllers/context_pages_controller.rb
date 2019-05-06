#
# We have a problem: every page type has a different controller.
# This means that we either have to declare the controller somehow
# in the route, or use a special dispatch controller that will pass
# on the request to the page's controller.
#
# We have it set up so that we can do both. A static route would look like:
#
#   /groups/riseup/wiki/show/40/
#
# A route using this dispatcher would look like this:
#
#   /riseup/title+40
#
# The second one is prettier, but perhaps it is slower? This remains to be seen.
#
# the idea was taken from:
# http://www.agileprogrammer.com/dotnetguy/archive/2006/07/09/16917.aspx
#
# the dispatcher handles urls in the form:
#
# /:context_handle/:page_handle/:page_action
#
# :context_handle can be a group name or user login
# :page_handle can be the name of the page or "#{title}+#{page_id}"
# :page_action is the action that should be passed on to the page's controller
#

class ContextPagesController < DispatchController
  protected

  def find_controller
    @page = finder.page
    @group = finder.group
    @user = finder.user
    new_controller controller_name
  end

  def finder
    @finder ||= Page::Finder.new params[:context_id],
                                 params[:id]
  end

  def controller_name
    if @page
      @page.controller
    else
      controller_for_missing_page
    end
  end

  def controller_for_missing_page
    if create_page?
      prepare_params_to_create_page
      'page/create'
    else
      prepare_params_for_not_found
      'exceptions'
    end
  end

  def create_page?
    logged_in? &&
      (create_group_page? || (@user == current_user))
  end

  def create_group_page?
    @group && current_user.may?(:edit, @group)
  end

  def prepare_params_to_create_page
    modify_action :new
    modify_params owner: @group.name if create_group_page?
    modify_params type: 'wiki',
                  page: { title: new_title }
  end

  def prepare_params_for_not_found
    request.env['action_dispatch.exception'] = ErrorNotFound.new(:page)
  end

  def new_title
    params[:id].sub(/\+\d*/, '').split('+').join(' ').humanize
  end

end
