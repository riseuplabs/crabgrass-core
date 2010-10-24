class Mods::Plugin::Loader < Rails::Plugin::Loader

  protected

  def register_plugin_as_loaded(plugin)
    if Mods.plugin_reloadable_callback and Mods.plugin_reloadable_callback.call(plugin.directory)
      plugin.reloadable
    end
    super plugin
  end

end
