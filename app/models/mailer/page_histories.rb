#
# Mailer that sends out the daily digests of page updates
#
# This is triggered from a chron job. At night in the early morning.
# It includes all updates from the day before. In order to ensure
# consistency please make sure deliver_all finishes on the same day it
# started.

class Mailer::PageHistories < ActionMailer::Base

  TIMESPAN = 1.day

  add_template_helper(Pages::HistoryHelper)
  add_template_helper(Common::Utility::TimeHelper)

  def self.deliver_digests
    digest_recipients.map do |recipient|
      # let's throttle this a bit. We have ~2000 recipients
      # So this will take 2000 sec. < 40 Minutes total.
      sleep 1
      digest(recipient).deliver
    end.tap do
      mark_all_as_send
    end
  end

  def digest(recipient)
    @recipient = recipient
    @site = Site.default || Site.new
    @histories = page_histories_for_recipient.includes(:page).
      order("page_histories.created_at")
    return if @histories.blank?
    mail to: recipient, subject: digest_subject, from: sender
  end

  protected

  def self.digest_recipients
    User.where(receive_notifications: 'Digest')
  end

  def self.mark_all_as_send
    page_histories.update_all notification_digest_sent_at: Time.now
  end

  # all relevant PageHistory records
  def self.page_histories
    PageHistory.where(notification_digest_sent_at: nil).
      where("DATE(page_histories.created_at) >= DATE(?)", TIMESPAN.ago).
      where("DATE(page_histories.created_at) < DATE(?)", Time.now)
  end

  def page_histories_for_recipient
    self.class.page_histories.where(page_id: watched_pages)
  end

  def watched_pages
    @recipient.pages.
      where(user_participations: {watch: true}).
      where("DATE(pages.updated_at) >= DATE(?)", TIMESPAN.ago)
  end

  def digest_subject
    I18n.t("mail.subject.daily_digest", site: @site.title)
  end

  def sender
    @site.email_sender.gsub('$current_host', @site.domain)
  end
end
