module Mailers::Group
  def group_destroyed_notification(recipient, group, options)
    setup(options)
    setup_destroyed_email(recipient, group, options)
  end

  protected

  def setup_destroyed_email(recipient, group, options)
    # @user may be nil
    @user = options[:current_user]
    @group = group
    @recipients = "#{recipient.email}"
    @subject = I18n.t(:group_destroyed_subject,
                        group_type: @group.group_type,
                        group: @group.full_name,
                        user: @user.try.display_name)

    mail from: @from, to: @recipients, subject: @subject
  end
end
