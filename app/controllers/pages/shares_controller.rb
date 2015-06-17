#
# PAGE SHARING
#
#
# Handles the sharing and notification of pages
#
# share this page with a notice message to any number of recipients.
#
# if the recipient is a user name, then the message and the page show up in
# user's inbox, and optionally they are alerted via email.
#
# if the recipient is an email address, an email is sent to the address with a
# magic url that lets the recipient view the page by clicking on a link
# and using their email as the password.
#
# the sending user must have admin access to send to recipients
# who do not already have the ability to view the page.
#
# the recipient may be an entire group, in which case we grant access
# to the group and send emails to each user in the group.
#
# you cannot share to users/groups that you cannot pester, unless
# the page is private and they already have access.
#
class Pages::SharesController < Pages::SidebarsController

  guard update: :may_share_page?

  helper 'pages/share', 'pages/participation'

  before_filter :close_popup, only: :update, if: :cancel_update?
  before_filter :add_recipients, only: :update, if: :add_recipients?

  # display the share or notify forms.
  # this returns the html, which is used to populate the modalbox
  def show
    render template: "pages/shares/show_#{mode_param}"
  end

  # there are two modes:
  #
  #  params[:share]  --> add new access, maybe notify
  #  params[:notify] --> send notice, maybe add access.
  #
  # there are four ways to submit the forms:
  #
  #   (1) cancel button (params[:cancel_button]==true)
  #       -> before_filter :close_popup
  #   (2) add button or return in add field (params[:add]==true)
  #       -> before_filter :add_recipients
  #   (3) share button (params[:share_button]==true)
  #   (3) notify button (params[:notify_button]==true)
  #
  # recipient(s) examples:
  #
  # * when updating the form:
  #   {"recipient"=>{"name"=>"", "access"=>"admin"}}
  #
  # * when submitting the form:
  #   {"recipients"=>{"aaron"=>{"access"=>"admin"},
  #    "the-true-levellers"=>{"access"=>"admin"}}
  #
  def update
    @success_message = I18n.t(notify_or_share_message)
    notify_or_share
  end

  protected

  #
  # Main Update Task
  #
  def notify_or_share
    if (params[:share_button] || params[:notify_button]) and params[:recipients]

      current_user.share_page_with!(@page, params[:recipients], share_options)
      @page.save!
      success(@success_msg)
    end
    close_popup
  end

  def share_options
    options = params[:notification] || HashWithIndifferentAccess.new
    convert_checkbox_boolean(options)
    options[:send_notice] ||= params[:notify_button].present?
    options.reverse_merge mailer_options: mailer_options
  end

  #
  # Before Filters
  #

  # we allow for an id of 0 for pages just getting created
  def fetch_page
    @page = Page.new if params['page_id'] == "0"
    @page || super
  end

  def cancel_update?
    params[:cancel_button]
  end

  def add_recipients
    @recipients = build_recipient_array
    render partial: 'pages/shares/add_recipient', locals: {alter_access: share?}
  end

  def add_recipients?
    params[:add]
  end

  #
  # Handling recipients
  #
  def build_recipient_array
    if params[:recipient] and params[:recipient][:name].present?
      recipients_names = params[:recipient][:name].strip.split(/[, ]/)
      recipients_names.map do |recipient_name|
        find_recipient(recipient_name, mode_param)
      end.compact
    else
      []
    end
  end

  #
  # given a recipient name, we try to find an appriopriate user or group object.
  # a lot can go wrong: the name might not exist, you may not have permission, the user might
  # already have access, etc.
  #
  def find_recipient(recipient_name, action=:share)
    recipient_name.strip!
    return nil unless recipient_name.present?
    recipient = User.find_by_login(recipient_name) || Group.find_by_name(recipient_name)
    if recipient.nil?
      error(:thing_not_found.t(thing: h(recipient_name)))
      return nil
    elsif !current_user.may?(:pester, recipient)
      error(:share_pester_error.t(name: recipient.name))
      return nil
    elsif @page
      upart = recipient.participations.find_by_page_id(@page.id)
      if upart && action == :share && !upart.access.nil?
        notice(:share_already_exists_error.t(name: recipient.name))
        return nil
      elsif upart.nil? && action == :notify
        if !recipient.may?(:view, @page) and !may_share_page?
          error(:notify_no_access_error.t(name: recipient.name))
          return nil
        end
      end
    end
    return recipient
  end

  private

  #
  # Utility Methods
  #
  SUCCESS_MESSAGES = { share: :shared_page_success, notify: :notify_success }

  def notify_or_share_message
    SUCCESS_MESSAGES[mode_param]
  end

  def mode_param
    mode = params[:mode]
    raise_error 'bad mode' unless ['notify', 'share'].include? mode
    mode.to_sym
  end

  def share?
    mode_param == :share
  end

  # convert {:checkbox => '1'} to {:checkbox => true}
  def convert_checkbox_boolean(hsh)
    hsh.each_pair do |key,val|
      if val == '0'
        hsh[key] = false
      elsif val == '1'
        hsh[key] = true
      end
    end
  end

end

