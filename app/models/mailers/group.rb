module Mailers::Group
  def group_destroyed_notification(recipient, event, options)
    setup(options)
    setup_destroyed_email(recipient, event)
  end

  protected

  def setup_destroyed_email(recipient, event)
    # @user may be nil
    @group = event[:group]
    @user = event[:user]
    @recipients = "#{recipient.email}"
    @subject = I18n.t(:group_destroyed_subject,
                        group_type: @group.group_type,
                        group: @group.full_name,
                        user: @user.try.display_name)

    mail from: @from, to: @recipients, subject: @subject
  end
end
