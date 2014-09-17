module Mailers::Verification

  def email_verification(token, options)
    setup(options)
    @link = account_verify_url(:token => token.value)
    mail :from => from, :to => @current_user.email,
      :subject => I18n.t(:welcome_title, :site_title => @site.title)
  end

end

