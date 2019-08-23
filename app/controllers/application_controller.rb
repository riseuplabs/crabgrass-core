# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery prepend: true

  layout proc { |c| c.request.xhr? ? false : 'application' } # skip layout for ajax

  include_controllers 'common/application'
  include_helpers 'app/helpers/common/*/*.rb'
  helper :application, :modalbox

  protected

  # this is used by the code that is included for both controllers and helpers.
  # this way, they don't need to know if they are in a view or a controller,
  # they can always just reference controller().
  def controller
    self
  end

  # view() method lets controllers have access to the view helpers.
  def view
    self.class.helpers
  end

  # proxy for view's content_tag
  def content_tag(*args, &block)
    view.content_tag(*args, &block)
  end

  #
  # returns a hash of options to be given to the mailers. These can be
  # overridden, but these defaults are pretty good. See models/mailer.rb.
  #
  def mailer_options
    from_address = current_site.email_sender
                               .sub('$current_host', request.host)
    from_name    = current_site.email_sender_name
                               .sub('$user_name', current_user.display_name)
                               .sub('$site_title', current_site.title)
    opts = {
      site: current_site, current_user: current_user,
      host: request.host,   protocol: request.protocol,
      page: @page,          from_address: from_address,
      from_name: from_name
    }
    opts[:port] = request.port_string.sub(':', '') if request.port_string.present?
    opts
  end
end
