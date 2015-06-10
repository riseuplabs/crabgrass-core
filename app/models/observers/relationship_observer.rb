class RelationshipObserver < ActiveRecord::Observer

  def before_create(relationship)
    # Relationship's are created in pairs
    mirror_twin = Relationship.find_by_user_id_and_contact_id(relationship.contact_id, relationship.user_id)

    # the first one will have no mirror_twin yet and will build a new Discussion
    # then that Relationship will get saved
    # the second Relationship int the pair will copy the discussion from the first one
    if mirror_twin and mirror_twin.discussion
      relationship.discussion_id = mirror_twin.discussion.id
    else
      relationship.create_discussion
    end
  end

end

