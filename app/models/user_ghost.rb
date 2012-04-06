class UserGhost < User

  def name
    :anonymous.t
  end
  alias :login :name
  alias :display_name :login

  # not clear if we want these all in one method, as we might want to have different levels of anonymizing
  def anonymize_user
    self.avatar.destroy
    remove_profiles
    self.setting.destroy
    self.task_participations.destroy
    self.tasks.destroy
    strip_comments
    remore_participations
    remove_memberships
    remove_relationships
    clear_cache
  end
  handle_asynchronously :make_user_ghost # this will use delayed_job

  private

  def remove_profiles
    self.profiles.destroy
  end

  def strip_comments
    self.posts.destroy
  end

  def remove_participations
    self.participations.destroy
  end

  def remove_memberships
    self.memberships.destroy
  end  
  
  def remove_relationships
    self.relationship.destroy
  end
  
end
