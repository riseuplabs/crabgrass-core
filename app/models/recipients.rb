#
# Recipients
#
# Recipients is a collection of entities that will receive a page or an invite.
#
# When they relate to a page they can have the special values :participants and
# :contributors which include all of the participants / contributors of the
# given page.
#
# Recipients.new is capable of parsing the most commen forms of form entries:
#
#  array form: ['green','blue','animals']
#  string form: 'green, blue, red'
#  hash form: {'green' => {:access => :admin}}
#             or {'green' => true}
#  object form: [#<User id: 4, login: "blue">]
#  special recipient: :contributors, :participants
#
# In the hash form options can be specified for each recipient.
# If the options are "0" the recipient is skipped. This is useful for checkboxes.

class Recipients

  attr_reader :options, :page, :param, :users, :groups, :emails, :specials

  def initialize(param, page = nil)
    @param, @options = param
    @options ||= {}
    @page = page

    # checked checkboxes will set options '1'
    @options = {} if @options == '1'
    # skip unchecked checkboxes
    @param = '' if @options == '0'
    @users, @groups, @emails, @specials = parse_recipients(@param)
  end

  def users_from_groups
    group_ids = groups.map(&:id) + groups_from_specials.map(&:id)
    User.joins(:memberships).
      where(memberships: {group_id: group_ids}).
      readonly(false).all
  end

  #
  # this is something of a hack, but much better than the hack it replaced.
  # in general, we have a big performance problem when trying to share/notify
  # a page with hundreds of people.
  #
  def users_from_specials
    specials.map do |special|
      case special
      when ':participants'
        page.users.all
      when ':contributors'
        page.users.contributed.all
      end
    end.flatten.uniq
  end

  def groups_from_specials
    return page.groups.all          if specials.include?(':participants')
    return []
  end

  # parses a list of recipients, turning them into email, user, or group
  # objects as appropriate.
  #
  # entity recipients:
  #
  #   array form: ['green','blue','animals']
  #   string form: 'green, blue, red'
  #   object form: [#<User id: 4, login: "blue">]
  #
  #   entity recipient names must not be symbols or strings that begin ':'
  #
  # special recipients:
  #
  #   :participants -- all the people who have access to the page.
  #   :contributors -- everyone who has ever modified the page.
  #
  #   special recipients can be symbols or strings that start with ':'
  #
  # returns an array [users, groups, emails, special] where:
  #
  #   [users]  an array of all parsed users
  #   [groups] an array of all parsed groups
  #   [emails] an array of all parsed emails
  #   [special] special recipients (:participants, etc)
  #
  def parse_recipients(recipients)
    users = []; groups = []; emails = []; specials = []; errors = []
    if recipients.is_a? Array
      entities = recipients
    elsif recipients.is_a? String
      entities = recipients.split(/[\s,]+/)
    else
      entities = [recipients]
    end

    entities.each do |entity|
      entity_string = (entity.is_a?(Symbol) ? ':' : '') + entity.to_s
      if entity.is_a? Group
        groups << entity
      elsif entity.is_a? User
        users << entity
      elsif entity_string.starts_with?(':')
        specials << entity
      elsif u = User.find_by_login(entity.to_s)
        users << u
      elsif g = Group.find_by_name(entity.to_s)
        groups << g
      elsif ValidatesEmailFormatOf.validate_email_format(entity.to_s).nil?
        emails << entity
      elsif entity.present?
        errors << I18n.t(:name_or_email_not_found, name: h(entity))
      end
    end

    unless errors.empty?
      raise ErrorMessages.new('Could not understand some recipients.', errors)
    end
    [users, groups, emails, specials]
  end # parse_recipients!
end
