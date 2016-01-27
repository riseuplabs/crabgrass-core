# work around for require_fixture_classes
# can probably be removed in rails 4.2
# This remove the error message:
# Unable to load page/term, underlying cause No such file to load -- page/term
#
# Rails expects the class related to page/terms.yml to live here.
require_relative 'terms'

Page::Term = Page::Terms
