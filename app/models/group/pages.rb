#
# Module that extends Group behavior.
#
# Handles all the group <> page relationships
#
module Group::Pages
  extend ActiveSupport::Concern

  included do
    has_many :participations,
      -> { order  :featured_position },
      class_name: 'Group::Participation',
      dependent: :delete_all,
      inverse_of: :group
    has_many :pages, through: :participations

    has_many :pages_owned, class_name: 'Page', as: :owner, dependent: :nullify
  end

  # Almost every page is retrieved from the database using this method.
  # (1) first, we attempt to load the page using the page owner directly.
  # (2) if that fails, then we resort to searching the entire
  #     namespace of the group
  #
  # Suppose two groups share a page. Only one can be the owner.
  #
  # When linking to the page from the owner's home, we just
  # do /owner-name/page-name. No problem, everyone is happy.
  #
  # But what link do we use for the non-owner's home? /non-owner-name/page-name.
  # This makes it so the banner will belong to the non-owner and it will not
  # be jarring click on a link from the non-owner's home and get teleported to
  # some other group.
  #
  # In order to make this work, we need the second query that includes all the
  # group participation objects.
  #
  # It is true that we could just do without the first query. It makes it slower
  # when the owner is not the context. However, this first query is much faster
  # and is likely to be used much more often than the second query.
  #
  def find_page(name)
    pages_owned.where(name: name).first ||
      pages.where(name: name).first
  end

  #
  # build or modify a group_participation between a group and a page
  # return the group_participation object, which must be saved for
  # changes to take effect.
  #
  def add_page(page, attributes)
    participation = page.participation_for_group(self)
    if participation
      participation.attributes = attributes
    else
      participation = page.group_participations.build attributes.merge(page_id: page.id, group_id: id)
    end
    page.association_will_change(:groups)
    page.groups_changed = true
    return participation
  end

  def remove_page(page)
    page.groups.delete(self)
    page.association_will_change(:groups)
    page.group_participations.reset
    page.groups_changed = true
    page
  end

  # DEPRECATED
  def may?(perm, page)
    begin
      may!(perm,page)
    rescue PermissionDenied
      false
    end
  end

  # DEPRECATED
  # perm one of :view, :edit, :admin
  # this is still a basic stub. see User.may!
  def may!(perm, page)
    gparts = page.participation_for_groups(group_and_committee_ids)
    if gparts.any?
      part_with_best_access = gparts.min {|a,b|
        (a.access||100) <=> (b.access||100)
      }
      return ( part_with_best_access.access || ACCESS[:view] ) <= (ACCESS[perm] || -100)
    else
      raise PermissionDenied.new
    end
  end

end

