# TODO: We currently use Site.default to originate from.
# Based on real live site scenarios we might want to make
# this the site where the user actually watched the page
# or the user last visited or the notification was send from.


module Mailers::PageHistory
  def self.included(base)
    base.instance_eval do
      # TODO: figure out which helpers are really needed.
      add_template_helper(Pages::HistoryHelper)
      #add_template_helper(PageHelper)
      #add_template_helper(Page::UrlHelper)
      add_template_helper(Common::Utility::TimeHelper)
    end
  end

  def page_history_single_notification(user, page_history, mailer_options = {})
    setup mailer_options
    @page_history   = page_history
    @user           = user
    @site           ||= Site.default
    if Conf.paranoid_emails?
      @subject      = I18n.t(:page_history_mailer_a_page_has_been_modified, site_title: @site.title)
      @code         = Code.create!(user: user, page: page_history.page)
      mail from: from_address, to: @user.email, subject: @subject,
        template_name: 'single_notification_paranoid'
    else
      @subject      = "#{@site.title} : #{@page_history.page.title}"
      mail from: from_address, to: @user.email, subject: @subject
    end
  end

  def page_history_digest_notification(user, page, page_histories)
    @site           = Site.default
    @user           = user
    @subject        = "#{@site.title} : #{page.title}"
    @page           = page
    @page_histories = page_histories
    mail from: from_address, to: @user.email, subject: @subject
  end

  def page_history_digest_notification_paranoid(user, page, page_histories)
    @site           = Site.default
    @user           = user
    @subject        = I18n.t(:page_history_mailer_a_page_has_been_modified, site_title: @site.title)
    @page           = page
    @page_histories = page_histories
    @code           = Code.create!(user: user, page: page)
    mail from: from_address, to: @user.email, subject: @subject
  end

  protected

  def from_address
    @site.email_sender.gsub('$current_host', @site.domain)
  end

end
