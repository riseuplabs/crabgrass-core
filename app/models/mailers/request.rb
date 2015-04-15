module Mailers::Request

  #
  # Send an email to invite some one to a group via email.
  #
  def invite_to_join_us(request, options)
    setup(options)
    @request = request
    @group = request.requestable
    @user = request.created_by
    @recipients = request.email
    @subject = I18n.t(:group_invite_subject, group: @group.display_name)
    mail from: @from, to: @recipients, subject: @subject
  end

  ###
  #  UPGRADE: These have not been ported over to core yet.
  #
  #  Please do so and keep in mind that rails3 has a new Mailer API:
  #
  #  1.)
  #      body :key => value
  #    now is replaced by
  #      @key = value
  #    just like in controllers.
  #  2.)
  #    call mail with subject, to, from at the end.
  #
  ###

  def request_to_destroy_our_group(request, user)
    # @group = request.group
    # @user = user
    # @created_by = request.created_by

    # # this is shitty
    # email_sender = @site.try.email_sender ? @site.email_sender : Conf.email_sender
    # domain = @site.try.domain ? @site.domain : Conf.domain
    # @from = email_sender.gsub('$current_host', domain)

    # @recipients = "#{user.email}"

    # @subject = I18n.t(:request_to_destroy_our_group_description,
    #                 :group => @group.full_name,
    #                 :group_type => @group.group_type.downcase,
    #                 :user => @created_by.display_name)

    # @request_link = url_for(:controller => 'me/requests/', :id => request.id)
    # @body[:user] = @created_by
    # @body[:group] = @group
  end

end

