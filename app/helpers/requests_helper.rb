require_relative 'comment_proxy_helper'

module RequestsHelper

  def posts_for_request(request = @request)
    [request_display_post(request), request_actions_post(request)].compact
  end

  def request_display_post(request)
    proxy_as_comment request, user: request.created_by,
      body_html: display_request(request),
      updated_at: nil
  end

  def request_actions_post(request)
    buttons = buttons_for_request(request)
    if buttons.present?
      proxy_as_comment request, user: active_user_for_request(request),
        body_html: buttons
    end
  end

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
