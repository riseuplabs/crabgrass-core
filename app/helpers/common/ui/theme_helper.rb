#
# Here are helpers specific to the particular themes that crabgrass uses.
#
# For helpers relating to the general theme plugin, see the plugin directory.
#

module Common::Ui::ThemeHelper
  def link_to_banner_title(entity)
    link_to_entity(entity, class: 'title', format: :full)
  end
end
