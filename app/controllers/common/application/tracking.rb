module Common::Application::Tracking

  protected

  # controllers should call this when they want to record a trackingevent.
  # e.g. in order to update the page view count.
  def track(options={})
    return unless current_site.tracking
    options.reverse_merge! current_user: current_user,
      group: @group,
      user: @user,
      action: :view
    Tracking::Page.insert_delayed options
  end

end
