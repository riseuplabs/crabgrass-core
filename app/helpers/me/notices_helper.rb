module Me::NoticesHelper
  def dismiss_all_notices_button
    link_to_remote(:dismiss_all_notices.t,
                   { confirm: "#{:dismiss_all_notices_confirmation.t}<br>#{:action_cannot_be_undone.t}",
                    url: me_notices_destroy_all_path,
                    method: :delete }, class: 'btn btn-sm btn-default')
  end

  def noticable_url(notice)
    send(notice.redirect_path, notice.redirect_object)
  rescue NoMethodError => e
    logger.error 'Error: ' + e.message
    logger.error e.backtrace.join("\n")
    return nil
  end
end
