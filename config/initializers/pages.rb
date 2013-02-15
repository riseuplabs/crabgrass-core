#
# this works here because initializers are run after plugins are loaded but
# before the application code is loaded.
#

require Rails.root.join('lib', 'crabgrass', 'page', 'class_registrar')

PAGES = Crabgrass::Page::ClassRegistrar.proxies.dup.freeze
Conf.available_page_types = PAGES.keys if Conf.available_page_types.empty?


