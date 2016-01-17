# -*- coding: utf-8 -*-
#
# A user's relationship to pages
#
# "user_participations" is the join table:
#   user has many pages through user_participations
#   page has many users through user_participations
#
module User::Pages
  include ActiveSupport::Benchmarkable

  ##
  ## ASSOCIATIONS
  ##

  def self.included(base)
    base.instance_eval do
      has_many :participations,
        class_name: 'User::Participation',
        dependent: :destroy,
        inverse_of: :user

      has_many :pages, through: :participations do
        def recent_pages
          order('user_participations.changed_at DESC').limit(15)
        end
      end

      has_many :pages_owned, class_name: 'Page', as: :owner, dependent: :nullify
      has_many :pages_created, class_name: 'Page', foreign_key: :created_by_id, dependent: :nullify
      has_many :pages_updated, class_name: 'Page', foreign_key: :updated_by_id, dependent: :nullify

      def self.most_active_on(site, time)
        condition = time && ["user_participations.changed_at >= ?", time]
        joins(user_participations: :pages).
          where(condition).
          where(pages => {site_id: site}).
          where("pages.type != 'AssetPage'").
          group('users.id').
          order('count(user_participations.id) DESC').
          select('users.*, user_participations.changed_at')
      end

      def self.most_active_since(time)
        joins(:user_participations).
          group('users.id').
          order('count(user_participations.id) DESC').
          where("user_participations.changed_at >= ?", time).
          select("users.*")
      end

      def self.not_inactive
        if self.respond_to? :inactive_user_ids
          where("users.id NOT IN (?)", inactive_user_ids)
        end
      end

      # some page data objects belong to users.
      # These need has many relationships so they get cleaned up if a user
      # is destroyed.
      has_many :votes,
        dependent: :destroy,
        class_name: 'Poll::Vote'

    end
  end

  # this is used to retrieve pages when vising
  #   /login/page_name
  # for now we only display pages the user actually owns.
  def find_page(name)
    pages_owned.where(name: name).first
  end

  ##
  ## USER PARTICIPATIONS
  ##

  #
  # makes or updates a user_participation object for a page.
  #
  # returns the user_participation, which must be saved for changed
  # to take effect.
  #
  # this method is not called directly. instead, page.add(user)
  # should be used.
  #
  # TODO: delete the user_participation row if it is not really needed
  # anymore (ie, the user won't lose access by deleted it, and inbox,
  # watch, star are all false, and the user has not contributed.)
  #
  def add_page(page, part_attrs)
    clear_access_cache
    part_attrs = part_attrs.dup
    participation = page.participation_for_user(self)
    if participation
      participation.attributes = part_attrs
    else
      # user_participations.build doesn't update the pages.users
      # until it is saved. If you need an updated users list, then
      # use user_participations directly.
      participation = page.user_participations.build(
        part_attrs.merge(
          page_id: page.id, user_id: id,
          resolved: page.resolved?
        )
      )
      participation.page = page
    end
    unless participation.changed_at or page.created_by != self
      participation.changed_at = Time.now
    end
    page.association_will_change(:users)
    participation
  end

  public

  # remove self from the page.
  # only call by page.remove(user)
  def remove_page(page)
    clear_access_cache
    page.users.delete(self)
    page.updated_by_id_will_change!
    page.association_will_change(:users)
    page.user_participations.reset
  end

  # set resolved status vis-à-vis self.
  def resolved(page, resolved_flag)
    find_or_build_participation(page).update_attributes resolved: resolved_flag
  end

  def find_or_build_participation(page)
    page.participation_for_user(self) || page.user_participations.build(user_id: self.id)
  end

  # This should be called when a user modifies a page and that modification
  # should trigger a notification to page watchers. Also, if a page state changes
  # from pending to resolved, we also update everyone's user participation.
  # The page is not saved here, because it might still get more changes.
  # An after_filter should finally save the page if it has not already been saved.
  #
  # options:
  #  :resolved -- user's participation is resolved with this page
  #  :all_resolved -- everyone's participation is resolved.
  #
  def updated(page, options={})
    benchmark 'User#updated' do
      return if page.blank?
      now = Time.now

      unless page.contributor?(self)
        page.contributors_count += 1
      end

      # update everyone's participation
      if options[:all_resolved]
        page.user_participations.update_all('viewed = 0, resolved = 1')
      else
        page.user_participations.update_all('viewed = 0')
      end

      # create self's participation if it does not exist
      my_part = find_or_build_participation(page)
      my_part.update_attributes(
        changed_at: now, viewed_at: now, viewed: true,
        resolved: (options[:resolved] || options[:all_resolved] || my_part.resolved?)
      )

      # this is unfortunate, because perhaps we have already just modified the page?
      page.resolved = options[:all_resolved] || page.resolved?
      page.updated_at = now
      page.updated_by = self
      page.user_participations.where(watch: true).each do |part|
        notices = PageUpdateNotice.for_page(page).where(dismissed: false, user_id: part.user_id)
          .select { |notice| notice.data[:from] == self.name }
        if notices.any?
          notices.each &:touch
        else
          PageUpdateNotice.create!(user_id: part.user_id, page: page, from: self)
        end
      end
    end
  end


  # return true if the user may still admin a page even if we
  # destroy the particular participation object
  #
  # this method is VERY expensive to call, and should only be called with caution.
  def may_admin_page_without?(page, participation)
    # user_participations or group_participations
    method = participation.class.name.underscore.pluralize.sub('/', '_')
    # work with a new, untained page object
    # no changes to it should be saved!
    page = Page.find(page.id)
    page.send(method).delete_if {|part| part.id == participation.id}
    begin
      result = page.has_access!(:admin, self)
    rescue PermissionDenied
      result = false
    end
    result
  end
end
