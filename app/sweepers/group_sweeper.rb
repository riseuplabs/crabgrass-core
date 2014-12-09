class GroupSweeper < ActionController::Caching::Sweeper

  observe Group

  def before_update(group)
    return unless group.avatar_id_changed?
    group.pages_owned.each do |page|
      expire_fragment("v1-page-#{page.id}-#{page.update_hash}")
    end
  end

end
