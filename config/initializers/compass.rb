unless defined?(UNIT_TESTING)

  # If you have any compass plugins, require them here.
  require 'compass'

  Compass.add_project_configuration(File.join(Rails.root, "config", "misc", "compass.config"))
  Compass.configuration.environment = Rails.env.to_sym
  Compass.configure_sass_plugin!

  #
  # We handle the rendering of sass files ourselves, via the crabgrass_theme plugin.
  # (The theme generates sass that includes variables set by the theme)
  #
  # Consequently, it is important that we force sass to not automatically render
  # the css files itself.
  #
  Sass::Plugin.options[:never_update] = true
end
