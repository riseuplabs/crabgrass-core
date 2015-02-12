class UserGhost < User

  def login
    read_attribute(:login).presence || 'none'
  end

  def display_name
    read_attribute(:display_name).presence || :deleted.t
  end

  #
  # retire this user.
  #
  # 1. removes all group memberships
  # 2. removes all user relationships
  # 3. removes user data like profiles
  #
  def retire!
    avatar.destroy if avatar
    # setting.destroy #TODO not sure if settings are ever used.
    profiles.destroy_all
    task_participations.destroy_all
    participations.destroy_all
    memberships.destroy_all # should we use remove_user! ?
    relationships.each { |relationship| self.remove_contact!(User.find(relationship.contact_id)) }
    keys.destroy_all
    clean_attributes
    clear_cache
  end
  #handle_asynchronously :retire!

  #
  # gets rid of the users name
  #
  def anonymize!
    self.update_attributes(display_name: nil, login: nil)
  end
  #handle_asynchronously :anonymize!

  #
  # gets rid of all comments
  #
  def destroy_comments!
    self.posts.each { |p| p.destroy }
  end
  #handle_asynchronously :destroy_comments!

  # can't do anything with a user_ghost
  def has_access!(_perm, _user)
    false
  end

  def ghost?
    true
  end

  def password_required?
    false
  end

  private

  def clean_attributes
    attrs_to_keep = %w(id type login display_name)
    clean_attrs = attributes.except(*attrs_to_keep)
    clean_attrs.each { |k, _v| clean_attrs[k] = nil }
    update_attributes clean_attrs
    # updated_at should be last so it isn't re-set
    update_attribute("updated_at", nil)
  end

end
