#
# Page Share
#
# PageShare is a utility class to help sharing a page with multiple recipients.
#
# This is the only method that should ever be used when a user is sharing a page
# with a user or group and/or sending a notification. It will make sure mails
# get send and so on.
#
# A PageShare instance captures the process of sharing a specific page as a
# specific user with some options.
#
# Usage:
# share = PageShare.new page, sender, defaults
# share.with recipients
#
# The user and group participations affected are returned as two arrays.
# An exception is thrown if there are any permissions problems.
#
# There are also special recipient names that start with ":", such as :contributors.
# See models/recipient.rb for details.
#
# Please keep the instance immutable. This way we do not have to worry about
# changes to the PageShare state and can focus on the effects it has on other classes.
#
# valid options:
#         :access -- sets access level directly. one of nil, :admin, :edit, or
#                    :view. (nil will remove access)
#   :grant_access -- like :access, but is only used to improve access, not
#                    remove it.
#
#    :send_notice -- boolean. If true, then the page will end up in the
#                    recipient's notice list and the following additional
#                    flags are taken into account:
#       :send_email -- boolean, send a copy of notice via email?
#     :send_message -- text, the message to include with the notification, if any.
#   :mailer_options -- required when sending email
#
# The needed user_participation and group_partication objects will get saved
# unless page is modified, in which case they will not get saved.
# (assuming that page.save will get called eventually, which will then save
# the new participation objects. BasePageController has an after_filter that
# auto saves the @page if has been changed.)
#

class PageShare

  attr_reader :page, :sender, :defaults

  def initialize(page, sender, defaults = {})
    @page = page
    @sender = sender
    @defaults = defaults.with_indifferent_access
  end

  def with(recipient_params)
    recipients = build_recipients(recipient_params)
    share_and_email(recipients)
  end

  protected

  def build_recipients(recipient_params)
    Array(recipient_params).map! do |param|
      Recipients.new(param, page)
    end
  end

  def share_and_email(recipients)
    share_with_recipients(recipients).tap do |uparts, _gparts|
      send_notices uparts.map(&:user) if send_notices?
      send_emails uparts.map(&:user) if send_emails?
    end
  end

  # share the page, given an array of recipients
  # returns: the affected user participations and group participations in
  # two separate arrays
  #
  def share_with_recipients(recipients)
    uparts = recipients.map do |rec|
      share_with_users_from_recipient(rec)
    end.flatten.uniq

    gparts = recipients.map do |rec|
      share_with_groups(rec.groups + rec.groups_from_specials, rec.options)
    end.flatten.uniq

    return uparts, gparts
  end

  # if we notify people the page should show up on their dashboard
  # so we have to add a participation for them personally even if
  # they are notified via a group.
  def share_with_users_from_recipient(rec)
    uparts = share_with_users(rec.users + rec.users_from_specials, rec.options)
    if send_notices?
      uparts += share_with_users rec.users_from_groups,
        rec.options.merge(access: nil)
    end
    uparts
  end

  def share_with_users(users, options = {})
    options = defaults.merge options
    users.map{|user| share_with_user!(user, options)}
  end

  def share_with_groups(groups, options = {})
    options = defaults.merge options
    groups.map{|group| share_with_group!(group, options)}
  end

  def share_with_user!(user, options={})
    may_share_with_user!(user, options)

    page.add(user, user_participation_attrs(user, options)).tap do |upart|
      upart.save! unless page.changed?
    end
  end

  def share_with_group!(group, options={})
    may_share_with_group!(group, options)

    page.add(group, group_participation_attrs(options)).tap do |gpart|
      gpart.save! unless page.changed?
    end
  end

  def user_participation_attrs(user, options)
    attrs = {}
    attrs[:viewed] = false if send_notices?
    default_access_level = :none
    if options.key?(:access) # might be nil
      attrs[:access] = options[:access]
    else
      options[:grant_access] ||= default_access_level
      unless user.may?(options[:grant_access], page)
        attrs[:grant_access] = options[:grant_access]
      end
    end
    attrs
  end

  def group_participation_attrs(options)
    if options.key?(:access) # might be nil
      { access: options[:access] }
    else
      { grant_access: options[:grant_access] || :view}
    end
  end

  # Check that +self+ may pester user and has admin access if sharing requires
  # granting new access.
  #
  def may_share_with_user!(user, options)
    access = options[:access] || options[:grant_access] || :view
    error = page_sharing_error(user, access)
    if error
      message = I18n.t error, name: user.login
      raise PermissionDenied.new(message)
    end
  end

  def page_sharing_error(user, access)
    if page.public? and !sender.may?(:pester, user)
      :share_pester_error
    elsif access.nil?
      if !user.may?(:view,page)
        :share_grant_required_error
      end
    elsif !user.may?(access, page)
      if !sender.may?(:admin,page)
        :share_permission_denied_error
      elsif !sender.may?(:pester, user)
        :share_pester_error
      end
    end
  end

  def may_share_with_group!(group, options)
    access = options[:access] || options[:grant_access] || :view
    unless group.may?(access, page)
      unless sender.may?(:admin, page) and sender.may?(:pester, group)
        raise PermissionDenied.new(I18n.t(:share_pester_error, name: group.name))
      end
    end
  end

  def send_notices?
    defaults[:send_notice]
  end

  def send_notices users
    PageNotice.create! recipients: users,
      page: page,
      from: sender,
      message: defaults[:send_message]
  end

  def send_emails?
    send_notices? && defaults[:mailer_defaults] && defaults[:send_email]
  end

  def send_emails(users)
    users.select!(&:wants_notification_email?)
    users.each do |user|
      #logger.debug '----------------- emailing %s' % user.email
      mail = Mailer.share_notice user,
        defaults[:send_message],
        defaults[:mailer_options]
      mail.deliver
    end
  end

end
