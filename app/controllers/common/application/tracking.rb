module Common::Application::Tracking

  protected

  # controllers should call this when they want to record a trackingevent.
  # e.g. in order to update the page view count.
  def track(options={})
    if current_site.tracking
      Tracking.delayed_insert({current_user: current_user, group: @group, user: @user, action: :view}.merge(options))
    end
  end

end
