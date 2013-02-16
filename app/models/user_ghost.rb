class UserGhost < User

  def name
    if read_attribute(:display_name).nil?
      :anonymous.t
    else
      read_attribute(:display_name)
    end
  end
  alias :login :name
  alias :display_name :login

  #
  # retire this user.
  #
  # 1. removes all group memberships
  # 2. removes all user relationships
  # 3. removes user data like profiles
  #
  def retire!
    clean_attributes
    avatar.destroy if avatar
    profiles.each { |p| p.destroy }
    # setting.destroy #TODO not sure if settings are ever used.
    task_participations.each { |t| t.destroy }
    participations.each { |p| p.destroy }
    memberships.each { |m| m.destroy } # should we use remove_user! ?
    relationships.each { |relationship| self.remove_contact!(User.find(relationship.contact_id)) }
    clear_cache
  end
  #handle_asynchronously :retire!

  #
  # gets rid of the users name
  #
  def anonymize!
    self.update_attribute(:display_name, nil)
  end
  #handle_asynchronously :anonymize!

  #
  # gets rid of all comments
  #
  def destroy_comments!
    self.posts.each { |p| p.destroy }
  end
  #handle_asynchronously :destroy_comments!

  private

  def clean_attributes
    #
    # use update_attribute to bypass the validations
    #
    attrs_to_nil_out = %w(
      crypted_password salt time_zone email
      login created_at version
      last_seen_at language remember_token remember_token_expires_at
      updated_at
    ) # updated_at should be last so it isn't re-set
    attrs_to_nil_out.each do |attr|
      update_attribute(attr, nil)
    end
  end

end
