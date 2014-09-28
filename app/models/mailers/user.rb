module Mailers::User

  def forgot_password(token, options)
    setup(options)
    setup_email(token.user)
    @subject += I18n.t(:requested_forgot_password)
    @url = reset_password_url(token: token.value)
    mail from: @from, to: @recipients, subject: @subject
  end

  def reset_password(user, options)
    setup(options)
    setup_email(user)
    @subject += I18n.t(:password_was_reset)
    mail from: @from, to: @recipients, subject: @subject
  end

  protected

  def setup_email(user)
    @recipients   = "#{user.email}"
    @from         = "%s <%s>" % [I18n.t(:reset_password), @from_address]
    @subject      = @site.title + ": "
    @user       ||= user
  end

end
