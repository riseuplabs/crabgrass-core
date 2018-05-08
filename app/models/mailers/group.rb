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
    @recipients = recipient.email.to_s
    @subject = I18n.t(:group_destroyed_subject,
                      group_type: t(@group.group_type.downcase),
                      group: @group.full_name,
                      user: @user.try.display_name)

    mail from: @from, to: @recipients, subject: @subject
  end
end
