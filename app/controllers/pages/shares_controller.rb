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

  guard :update => :may_share_page?

  verify :xhr => true

  helper 'pages/share', 'pages/participation'

  # display the share or notify forms.
  # this returns the html, which is used to populate the modalbox
  def show
    if params[:mode] == 'share'
      render :template => 'pages/shares/show_share'
    elsif params[:mode] == 'notify'
      render :template => 'pages/shares/show_notify'
    else
      raise_error 'bad mode'
    end
  end

  # there are two modes:
  #
  #  params[:share]  --> add new access, maybe notify
  #  params[:notify] --> send notice, maybe add access.
  #
  # there are four ways to submit the forms:
  #
  #   (1) cancel button (params[:cancel_button]==true)
  #   (2) add button or return in add field (params[:add]==true)
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
    if params[:mode] == 'share'
      @success_msg = I18n.t(:shared_page_success)
      notify_or_share(:share)
    elsif params[:mode] == 'notify'
      @success_msg = I18n.t(:notify_success)
      notify_or_share(:notify)
    else
      raise_error 'bad mode'
    end
  end

  protected

  def notify_or_share(action)
    if params[:cancel_button]
      close_popup
    elsif params[:add]
      @recipients = []
      if params[:recipient] and params[:recipient][:name].any?
        recipients_names = params[:recipient][:name].strip.split(/[, ]/)
        recipients_names.each do |recipient_name|
          @recipients << find_recipient(recipient_name, action)
        end
        @recipients.compact!
      end
      render :partial => 'pages/shares/add_recipient', :locals => {:alter_access => action == :share}
    elsif (params[:share_button] || params[:notify_button]) and params[:recipients]
      options = params[:notification] || HashWithIndifferentAccess.new
      convert_checkbox_boolean(options)
      options[:mailer_options] = mailer_options()
      options[:send_notice] ||= params[:notify_button].any?

      current_user.share_page_with!(@page, params[:recipients], options)
      @page.save!
      success(@success_msg)

      close_popup
    else
      close_popup
    end
  end

  ##
  ## UI METHODS FOR THE SHARE & NOTIFY FORMS
  ##

  #def show_error_message
  #  render :template => 'base_page/show_errors'
  #end

  #
  # given a recipient name, we try to find an appriopriate user or group object.
  # a lot can go wrong: the name might not exist, you may not have permission, the user might
  # already have access, etc.
  #
  def find_recipient(recipient_name, action=:share)
    recipient_name.strip!
    return nil unless recipient_name.any?
    recipient = User.find_by_login(recipient_name) || Group.find_by_name(recipient_name)
    if recipient.nil?
      error(:thing_not_found.t(:thing => h(recipient_name)))
      return nil
    elsif !recipient.may_be_pestered_by?(current_user)
      error(:share_pester_error.t(:name => recipient.name))
      return nil
    elsif @page
      upart = recipient.participations.find_by_page_id(@page.id)
      if upart && action == :share && !upart.access.nil?
        notice(:share_already_exists_error.t(:name => recipient.name))
        return nil
      elsif upart.nil? && action == :notify
        if !recipient.may?(:view, @page) and !may_share_page?
          error(:notify_no_access_error.t(:name => recipient.name))
          return nil
        end
      end
    end
    return recipient
  end

  private

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

