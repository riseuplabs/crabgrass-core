# apply some unit testing optimizations
UNIT_TESTING = true unless defined? UNIT_TESTING
require File.dirname(__FILE__) + '/../test_helper'

# stubbing out controller helpers
class ActionView::Base
  def page_url(page, *options)
    "http://url.for.page/#{page.title.underscore}"
  end

  def me_settings_url(options = {})
    "#{options[:host] || "host://"}me/settings_url"
  end
end
