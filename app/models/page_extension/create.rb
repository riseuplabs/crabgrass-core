module PageExtension::Create
  def self.included(base)
    base.extend(ClassMethods)
    #base.instance_eval do
    #  include InstanceMethods
    #end
  end

  #
  # special magic page create
  #
  # just like a normal activerecord.create, but with some magic options that
  # may optionally be passed in as attributes:
  #
  #  :user -- the user creating the page. they become the creator and owner
  #           of the page.
  #  :share_with -- other people, groups, or emails to share this page with.
  #  :access -- what access to grant them (defaults to :admin)
  #  :inbox -- send page to inbox?
  #
  # if anything goes wrong, an exception is raised, so watch out.
  # see UserExtension::Sharing#may_share_page_with!
  #
  # There are two versions create!() and create(). Both might throw exceptions
  # caused by bad sharing, but the first one will also throw exceptions if the
  # attributes don't validate.
  #
  module ClassMethods
    def create!(attributes = {}, &block)
      page = build!(attributes, &block)
      page.save!
      page
    end

    def create(attributes={}, &block)
      begin
        create!(attributes, &block)
      rescue ActiveRecord::RecordInvalid => exc
        exc.record
      end
    end

    #
    # build a page in memory, but don't save anything.
    #
    def build!(attributes={}, &block)
      if attributes.is_a?(Array)
        # act like normal create
        super(attributes, &block)
      else
        # extract extra attributes
        attributes = attributes.dup
        user       = attributes.delete(:user)
        owner      = attributes.delete(:owner)
        recipients = attributes.delete(:share_with)
        inbox      = attributes.delete(:inbox)
        access     = (attributes.delete(:access) || :admin).to_sym
        attributes[:created_by] ||= user
        attributes[:updated_by] ||= user

        Page.transaction do
          page = new(attributes)
          page.owner = owner if owner
          yield(page) if block_given?
          if user
            if recipients
              user.share_page_with!(page, recipients, :access => access,
                                    :send_notice => inbox)
            end
            # Page#owner= creates a user participation for the owner. Creating it
            # here is only needed, if the page is created for a different owner.
            # Also the participation may have been created through share_page_with!.
            # In either case we want "access" to be set to "admin" and "changed_at"
            # set as well (so the page shows up under "Recent Pages" on the dash)
            participation = page.user_participations.select { |part|
              part.user == user
            }.first || page.user_participations.build(:user_id => user.id)
            participation.access = ACCESS[:admin]
            participation.changed_at = Time.now
          end
          page
        end
      end
    end

    # parses a list of recipients, turning them into email, user, or group
    # objects as appropriate.
    #
    # entity recipients:
    #
    #   array form: ['green','blue','animals']
    #   hash form: {'green' => {:access => :admin}}
    #              or {'green' => true}
    #   object form: [#<User id: 4, login: "blue">]
    #
    #   entity recipient names must not be symbols or strings that begin ':'
    #
    # special recipients:
    #
    #   :participants -- all the people who have access to the page.
    #   :contributors -- everyone who has ever modified the page.
    #   :all -- share with the whole site.
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
    def parse_recipients!(recipients)
      users = []; groups = []; emails = []; specials = []; errors = []
      if recipients.is_a? Hash
        entities = []
        recipients.each do |key,value|
          if value.is_a?(Hash) or value == "1" or value === true
            entities << key
          end
        end
      elsif recipients.is_a? Array
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
        elsif entity =~ RFC822::EmailAddress
          emails << entity
        elsif entity.present?
          errors << I18n.t(:name_or_email_not_found, :name => h(entity))
        end
      end

      unless errors.empty?
        raise ErrorMessages.new('Could not understand some recipients.', errors)
      end
      [users, groups, emails, specials]
    end # parse_recipients!

  end # ClassMethods
end # PageExtension::Create


