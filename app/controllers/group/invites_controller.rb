#
# group_invites  GET    /groups/:group_id/invites action=>"index"
#                POST   /groups/:group_id/invites action=>"create"
#
# update and destroy are handled by Me::RequestsController

class Group::InvitesController < Group::BaseController

# requrires may_admin_group? as Group::BaseController
# TODO: if it is an open group, admin should not be required.

  def new
  end

  #
  # create some new invites, possibly of the type:
  #
  # RequestToJoinUs
  # RequestToJoinOurNetwork
  # RequestToJoinUsViaEmail
  #
  def create
    recipients = Page::Recipients.new(params[:recipients])
    users  = recipients.users
    groups = @group.network? ? recipients.groups : []
    emails = recipients.emails

    reqs, mailers = [], []
    unless users.any? or emails.any? or groups.any?
      raise_error('Recipient required')
    end

    users.each do |user|
      reqs << RequestToJoinUs.create(created_by: current_user,
        recipient: user, requestable: @group)
    end

    groups.each do |group|
      reqs << RequestToJoinOurNetwork.create(created_by: current_user,
        recipient: group, requestable: @group)
    end

    emails.each do |email|
      req = RequestToJoinUsViaEmail.create(created_by: current_user,
         email: email, requestable: @group, language: I18n.locale.to_s)
      Mailer.invite_to_join_us(req, mailer_options).deliver
      reqs << req
    end

    if reqs.detect { |req| !req.valid? }
      reqs.each do |req|
        alert_message req
        RequestNotice.create! req if req.valid? && !req.is_a?(RequestToJoinUsViaEmail)
      end
    else
      success reqs.first, count: reqs.size
      params[:recipients] = ""
      reqs.each { |req| RequestNotice.create! req if !req.is_a?(RequestToJoinUsViaEmail) }
    end

    redirect_to action: :new
  end

end
