#
# There is a lot of navigation code through crabgrass, done in really different
# ways. This helper is to bring some uniformity and sanity to how we specify
# navigation sidebars, tabs, menus, and sets of links.
#

# label
# icon
# url
# function
# active

module Common::Ui::NavigationHelper
  protected

  def active_top_nav
    current_theme.navigation.root.currently_active_item
  end

  def breadcrumb_divider
    '<span class="divider">&raquo;</span>'.html_safe
  end

end
