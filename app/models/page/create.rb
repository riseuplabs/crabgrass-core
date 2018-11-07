module Page::Create
  def self.included(base)
    base.extend(ClassMethods)
    # base.instance_eval do
    #  include InstanceMethods
    # end
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

    def create(attributes = {}, &block)
      create!(attributes, &block)
    rescue ActiveRecord::RecordInvalid => exc
      exc.record
    end

    #
    # build a page in memory, but don't save anything.
    #
    def build!(attributes = {}, &block)
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
        if attributes[:tag_list]
          attributes[:tag_list] = attributes[:tag_list].downcase # TODO: find a better solution
        end
        Page.transaction do
          page = new(attributes)
          page.owner = owner if owner
          yield(page) if block_given?
          if user
            if recipients
              share = Page::Share.new page, user,
                                      access: access,
                                      send_notice: inbox
              share.with recipients
            end
            # Maybe we already build a user participation because the user
            # is going to be the owner or shared with one of their groups
            # with notification.
            # Please note that at this point the participation only exists
            # in memory. So do not try to use where(user_id: ...) here.
            if page.owner.is_a? User or (page.owner.is_a? Group and page.owner.public? and !user.member_of? page.owner)
              participation = page.user_participations.select do |part|
                part.user == user
              end.first
              participation ||= page.user_participations.build(user_id: user.id)
              participation.access = ACCESS[:admin]
              participation.changed_at = Time.now
            end
          end
          page
        end
      end
    end
  end # ClassMethods
end # Page::Create
