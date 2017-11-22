#
# Mailer that sends out the daily digests and notifications about page updates
#
# This is triggered from a chron job. At night in the early morning.
# It includes all updates from the day before. In order to ensure
# consistency please make sure deliver_all finishes on the same day it
# started.

class Mailer::PageHistories < ActionMailer::Base
  DIGEST_TIMESPAN = 1.day
  UPDATE_TIMESPAN = 1.hour

  add_template_helper(Page::HistoryHelper)
  add_template_helper(Common::Utility::TimeHelper)

  def self.deliver_digests
    digest_recipients.map do |recipient|
      # let's throttle this a bit. We have ~2000 recipients
      # So this will take 2000 sec. < 40 Minutes total.
      sleep 1
      digest(recipient).deliver
    end.tap do
      mark_digests_as_send
    end
  end

  def self.deliver_updates_for(page, options = {})
    recipients = options[:to] || []
    recipients.map do |recipient|
      updates(page, recipient).deliver
    end.tap do
      mark_updates_as_send(page)
    end
  end

  def digest(recipient)
    init_mail_to(recipient)
    @histories = page_histories_for(recipient).includes(:page)
    mail subject: digest_subject
  end

  def updates(page, recipient)
    init_mail_to(recipient)
    @histories = page.page_histories.includes(:page)
                     .where('page_histories.created_at >= ?', UPDATE_TIMESPAN.ago)
                     .where(page_histories: { notification_sent_at: nil })
    mail subject: update_subject, template_name: :digest
  end

  protected

  def add_encrypt_options(options)
    return options unless @recipient.try.pgp_key
    key = @recipient.pgp_key.key
    # the users key is automatically imported into our keyring
    gpg_options =  {encrypt: true, keys: { @recipient.email => key }}
   # gpg_options = add_sign_options(gpg_options)  # FIXME: does not work on build system. do we want a dummy key there?
    options.merge gpg: gpg_options
  end

  def add_sign_options(gpg_options)
    # FIXME: this has to be done elsewhere 
    ENV['GPGKEY'] = Rails.root.join('assets','keyfile', 'robot_secret_key.asc').to_s
    GPGME::Key.import File.open(ENV['GPGKEY'])
    gpg_options.merge sign_as: "robot@riseup.net"
  end


  def init_mail_to(recipient)
    @site = Site.default
    @recipient = recipient
  end

  # add some defaults
  def mail(options = {})
    return if @histories.blank? || @recipient.email.blank?
    @histories = @histories.group_by(&:page).to_a
    options = add_encrypt_options(options)
    super options.reverse_merge from: sender, to: @recipient.email
  end

  def self.digest_recipients
    User.where(receive_notifications: 'Digest')
  end

  def self.mark_digests_as_send
    page_histories.update_all notification_digest_sent_at: Time.now
  end

  def self.mark_updates_as_send(page)
    page.page_histories.update_all notification_sent_at: Time.now
  end

  # all relevant PageHistory records
  def self.page_histories
    Page::History.where(notification_digest_sent_at: nil)
                 .where('DATE(page_histories.created_at) >= DATE(?)', DIGEST_TIMESPAN.ago)
  end

  def page_histories_for(user)
    self.class.page_histories.where(page_id: watched_pages(user))
  end

  def watched_pages(user)
    user.pages
        .where(user_participations: { watch: true })
        .where('DATE(pages.updated_at) >= DATE(?)', DIGEST_TIMESPAN.ago)
  end

  def digest_subject
    I18n.t('mailer.page_histories.daily_digest', site: @site.title)
  end

  def update_subject
    I18n.t('mailer.page_histories.page_update', site: @site.title)
  end

  def sender
    @site.email_sender.gsub('$current_host', @site.domain)
  end
end
