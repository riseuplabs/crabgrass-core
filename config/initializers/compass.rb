unless UNIT_TESTING

  # If you have any compass plugins, require them here.
  require 'compass'

  Compass.add_project_configuration(File.join(RAILS_ROOT, "config", "misc", "compass.config"))
  Compass.configuration.environment = RAILS_ENV.to_sym
  Compass.configure_sass_plugin!

end
