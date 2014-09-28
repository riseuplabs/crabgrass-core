class UserSweeper < ActionController::Caching::Sweeper

  observe User

  def before_update(user)
    return unless user.avatar_id_changed?
    Page.where(updated_by_id: user).each do |page|
      expire_fragment("v1-page-#{page.id}-#{page.update_hash}")
    end
    user.pages_owned.where("updated_by_id <> #{user.id}").each do |page|
      expire_fragment("v1-page-#{page.id}-#{page.update_hash}")
    end
  end

end
