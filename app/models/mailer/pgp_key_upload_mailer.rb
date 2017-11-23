#
# Mailer that sends an encrypted mail to the user after the upload of a new PGP key
#

class Mailer::PgpKeyUploadMailer < ActionMailer::Base

  def key_uploaded_mail(recipient)
    @site = Site.default
    @recipient = recipient
    setup_email(recipient)
  end

  protected

  def setup_email(recipient, options = {})
    options = add_encrypt_options(options)
    mail options.reverse_merge from: sender, to: recipient.email, subject: subject, template_name: :pgp_key_uploaded
  end

  def add_encrypt_options(options)
    return options unless @recipient.pgp_key
    key = @recipient.pgp_key.key
    gpg_options =  {encrypt: true, keys: { @recipient.email => key }}
    options.merge gpg: gpg_options
  end

  def subject
    I18n.t('mailer.page_histories.daily_digest', site: @site.title)
  end

  def sender
    @site.email_sender.gsub('$current_host', @site.domain)
  end

end
