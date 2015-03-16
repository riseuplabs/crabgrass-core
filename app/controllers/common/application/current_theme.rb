module Common::Application::CurrentTheme
  extend ActiveSupport::Concern

  included do
    helper_method :current_theme
  end

  def current_theme
    @theme ||= Crabgrass::Theme[select_theme]
  end

  def select_theme
    switch_theme || current_site.theme
  end

  # in dev mode, allow switching themes. maybe allow anyone to switch themes...
  def switch_theme
    return unless Rails.env.development?
    theme = params[:theme] || session[:theme]
    session[:theme] = theme if Crabgrass::Theme.exists?(theme)
  end
end
