#
# this works here because initializers are run after plugins are loaded but
# before the application code is loaded.
#

PAGES = Crabgrass::Page::ClassRegistrar.proxies.dup.freeze
Conf.available_page_types = PAGES.keys if Conf.available_page_types.empty?


