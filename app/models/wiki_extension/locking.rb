#
# This is a wrapper for the lower level WikiLock class
# it adds lock permissions, breaking and section hierarchy
# see WikiLock for more info
#
# The rules for locks are this:
#
# (1) every wiki has a hierarchical structure of heading sections
# (2) When one section is locked, all the sections above and below it are also treated
#     as locked.
# (3) This means two locks can only co-exist if they are in sibling trees
#
#
module WikiExtension
  module Locking

    #
    # EXCEPTIONS
    #

    class LockedError < CrabgrassException
    end

    class SectionLockedError < LockedError
      def initialize(section, user, options = {})
        if section == :document
          super([
            :wiki_is_locked.t(:user => bold(user.name))
          ], options)
        else
          super([
            :cant_edit_section.t(:section => bold(section)),
            :user_locked_section.t(:section => bold(section), :user => bold(user.name))
          ], options)
        end
      end
    end

    class OtherSectionLockedError < LockedError
      def initialize(section, options = {})
        super(
          :other_section_locked_error.t(:section => bold(section)).html_safe,
          options
        )
      end
    end

    class SectionLockedOnSaveError < LockedError
      def initialize(section, user, options = {})
        if section == :document
          super([
            :wiki_is_locked.t(:user => bold(user.name)),
            :can_still_save.t,
            :changes_might_be_overwritten.t
          ], options)
        else
          super([
            :user_locked_section.t(:section => bold(section), :user => bold(user.name)),
            :can_still_save.t,
            :changes_might_be_overwritten.t
          ], options)
        end
      end
    end

    #
    # LOCK/UNLOCK
    #

    #
    # create a new exclusive lock for user
    #
    def lock!(section, user)
      return unless section_exists?(section)

      if section_edited_by?(user) and section_edited_by(user) != section
        #
        # NOTE: for now, we only allow the user a single lock. This is for UI
        # reasons more than anything else.
        #
        raise OtherSectionLockedError.new(section_edited_by(user))
      elsif may_modify_lock?(section, user)
        section_locks.lock!(section, user)
      else
        other_user = locker_of(section)
        section_they_have_locked = section_edited_by(other_user)
        raise SectionLockedError.new(section_they_have_locked, other_user)
      end
    end

    #
    # Forcibly unlock a section.
    #
    # The actual lock may be on a parent or child section, so we unlock the genealogy
    #
    def break_lock!(section)
      return unless section_exists?(section)
      section_locks.unlock!(structure.genealogy_for_section(section))
    end

    #
    # Release the section held by user.
    #
    def release_my_lock!(section, user)
      if may_modify_lock?(section, user)
        section_locks.unlock!(section)
      end
    end

    #
    # HELPERS
    #

    #
    # get a list of sections that the +user+ may not edit
    #
    # some sections are not locked, but should appear locked to this user
    # for example, a locked section might have a subsection, or a parent section
    # no one else should be able to edit either the subsection or the parent
    #
    def sections_locked_for(user)
      locked_sections = section_locks.sections_locked_for(user)
      appearant_locked_sections = []
      locked_sections.each do |section|
        appearant_locked_sections |= structure.genealogy_for_section(section)
      end
      appearant_locked_sections
    end

    # get a list of sections that the +user+ may edit
    def sections_open_for(user)
      all_sections - sections_locked_for(user)
    end

    def section_open_for?(section, user)
      sections_open_for(user).include?(section)
    end

    def section_locked_for?(section, user)
      sections_locked_for(user).include?(section)
    end

    # returns which user is responsible for locking a section
    def locker_of(section)
      section_locks.locks.each do |section_name, lock|
        # we found the user, if their locked section has in its genealogy
        # the section we're looking for
        return User.find_by_id(lock[:by]) if structure.genealogy_for_section(section_name).include?(section)
      end
      nil
    end

    # a section that +user+ is currently editing or _nil_
    def section_edited_by(user)
      section_locks.section_locked_by(user)
    end

    alias section_edited_by? section_edited_by

    protected

    def may_modify_lock?(section, user)
      user.present? && user.real? && !sections_locked_for(user).include?(section)
    end

    def section_exists?(section)
      all_sections.include?(section)
    end

  end
end
