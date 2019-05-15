#
# Superclass for requests creating a Membership.
#

class MembershipRequest < Request
  def initialize(*args)
    raise "Cannot directly instantiate a #{self.class}" if self.class == MembershipRequest
    super
  end

  def after_approval
    group.add_user! user
  rescue AssociationError => e
    raise PointlessAction, e.message
  end

  def event
    :create_membership
  end

  def event_attrs
    { user: user, group: group }
  end
end
