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

# we don't want to load the roots. So instead we create our own url_for
module ActionDispatch::Routing::UrlFor
  def url_for(options = {})
    "url://#{options.values.join('/')}"
  end
end
