module RequestsHelper

  def buttons_for_request(request)
    if request.pending?
      render 'common/requests/action_buttons', request: request
    elsif request.approved?
      content_tag(:button, :approved.t, class: 'btn btn-success disabled')
    elsif request.rejected?
      content_tag(:button, :rejected.t, class: 'btn btn-danger disabled')
    end
  end

  def active_user_for_request(request)
    if request.pending?
      current_user
    elsif request.approved?
      request.approved_by
    elsif request.rejected?
      request.rejected_by
    end
  end

  def display_request(request, options = {})
    options.reverse_merge! avatar: 'tiny', class: 'inline'
    if options.delete(:short)
      translatable = request.short_description
    else
      translatable = request.description
    end
    expand_links(options) do
      translate *translatable
    end
  end

end
