module Mailers::Page

  # Send an email letting the user know that a page has been 'sent' to them.
  def share_notice(user, notice_message, options)
    setup(options)
    if Conf.paranoid_emails?
      code = Page::AccessCode.create! user: user, page: @page
      page_link = link()
      notice_message = nil
    else
      code = nil
      page_link = link(@page.uri)
    end
    @notice_message = notice_message
    @from_user = @current_user
    @to = user
    @link = page_link
    @code = code
    mail from: @from, to: user.email,
      subject: I18n.t(:email_notice_subject, title: @page.title)
  end

end
