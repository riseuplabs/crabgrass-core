#
# Page Share
#
# PageShare is a utility class to help sharing a page with multiple recipients.
#
# A PageShare instance captures the process of sharing a specific page as a
# specific user with some options.
#
# Please keep the instance immutable. This way we do not have to worry about
# changes to the PageShare state and can focus on the effects it has on other classes.
#
# Usage:
# share = PageShare.new page, sender, defaults
# share.with recipients, options = {}
#
# This is the only method that should ever be used when a user is sharing a page
# with a user or group and/or sending a notification. It will make sure mails
# get send and so on.
#
# An exception is thrown if there are any permissions problems.
#
# There are also special recipient names that start with ":", such as :contributors.
# See models/page_extension/create.rb parse_recipients!() for details.
#
# valid recipients:
#
#  array form: ['green','blue','animals']
#  hash form: {'green' => {:access => :admin}}
#             or {'green' => true}
#  object form: [#<User id: 4, login: "blue">]
#  special recipient: :contributors, :participants
#
# In the hash form, {"recipient_name" => "0"} is skipped. This is useful for checkboxes.
#
# valid options:
#        :access -- sets access level directly. one of nil, :admin, :edit, or
#                   :view. (nil will remove access)
#  :grant_access -- like :access, but is only used to improve access, not remove it.
#
#  :send_notice  -- boolean. If true, then the page will end up in the recipient's notice list
#                   and the following additional flags are taken into account:
#
#       :send_email -- boolean, send a copy of notice via email?
#         :send_sms -- boolean, send a copy of notice vis sms? (unsupported)
#        :send_xmpp -- boolean, send a copy of notice vis jabber? (unsupported)
#   :send_encrypted -- boolean, only send if can be done securely (unsupported)
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

  def with(recipients, options = {})
    options = defaults.merge options
    users_to_email = share_with_recipients!(page, recipients, options)
    if options[:send_notice] and options[:mailer_options] and options[:send_email]
      send_notification_emails users_to_email,
        options.slice(:send_message, :mailer_options)
    end
  end

  protected

  def share_with_recipients!(page, recipients, options)
    if recipients.is_a?(Hash)
      share_with_recipient_hash!(page, recipients, options)
    else
      share_with_recipient_array!(page, recipients, options)
    end
  end

  def send_notification_emails(users_to_email, options)
    users_to_email.uniq!
    users_to_email.each do |user|
      #logger.debug '----------------- emailing %s' % user.email
      Mailer.share_notice(user, options[:send_message], options[:mailer_options]).deliver
    end
  end

  # share the page, given an array of recipients, or an individual recipient.
  # returns: a list of users to notify.
  def share_with_recipient_array!(page, recipients, options)
    users, groups, emails, specials = Page.parse_recipients!(recipients)
    users_to_email = []

    ## special recipients
    specials.each do |special|
      handle_special_recipient(special, page, users, groups)
    end

    ## add users to page
    users.each do |user|
      if sender.share_page_with_user!(page, user, options)
        users_to_email << user if user.wants_notification_email?
      end
    end

    ## add groups to page
    groups.each do |group|
      users_to_pester = sender.share_page_with_group!(page, group, options)
      users_to_pester.each do |user|
        users_to_email << user if user.wants_notification_email?
      end
    end

    return users_to_email
  end

  #
  # takes recipients in hash form, like so {:blue => {:access => :admin}}.
  # and then calls share_with_recipient_array! with the appropriate options.
  #
  # returns an array of users to notify.
  #
  # VERY IMPORTANT NOTE: Either all the keys must be symbols or the hash types
  # must be HashWithIndifferentAccess. You have been warned.
  #
  def share_with_recipient_hash!(page, recipients, global_options=HashWithIndifferentAccess.new)
    users = []
    recipients.each do |recipient,local_options|
      if local_options == "0"
        next # skip unchecked checkboxes
      else
        options = local_options.is_a?(Hash) ? global_options.merge(local_options) : global_options
        users.concat share_with_recipient_array!(page, recipient, options)
      end
    end
    return users
  end

  #
  # this is something of a hack, but much better than the hack it replaced.
  # in general, we have a big performance problem when trying to share/notify
  # a page with hundreds of people.
  #
  def handle_special_recipient(recipient, page, users, groups)
    if recipient == ':participants'
      groups.concat page.groups
      users.concat page.users
    elsif recipient == ':contributors'
      users.concat page.users.contributed
    elsif recipient == ':all'
      # todo
    end
  end


end
