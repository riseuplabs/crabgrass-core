# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  protect_from_forgery
  layout proc{ |c| c.request.xhr? ? false : 'application' } # skip layout for ajax

  include_controllers 'common/application'
  include_helpers 'app/helpers/common/*/*.rb'
  helper :application, :modalbox
  permissions :application

  class_attribute :stylesheets
  class_attribute :javascripts

  protected

  # this is used by the code that is included for both controllers and helpers.
  # this way, they don't need to know if they are in a view or a controller,
  # they can always just reference controller().
  def controller(); self; end

  def current_theme
    @theme ||= Crabgrass::Theme[select_theme]
  end
  helper_method :current_theme

  def select_theme
    switch_theme || current_site.theme
  end

  # in dev mode, allow switching themes. maybe allow anyone to switch themes...
  def switch_theme
    return unless Rails.env.development?
    theme = params[:theme] || session[:theme]
    session[:theme] = theme if Crabgrass::Theme.exists?(theme)
  end

  # view() method lets controllers have access to the view helpers.
  def view
    self.class.helpers
  end

  # proxy for view's content_tag
  def content_tag(*args, &block)
    view.content_tag(*args,&block)
  end

  #
  # returns a hash of options to be given to the mailers. These can be
  # overridden, but these defaults are pretty good. See models/mailer.rb.
  #
  def mailer_options
    from_address = current_site.email_sender.
      sub('$current_host',request.host)
    from_name    = current_site.email_sender_name.
      sub('$user_name', current_user.display_name).
      sub('$site_title', current_site.title)
    opts = {
     :site => current_site,   :current_user => current_user,
     :host => request.host,   :protocol => request.protocol,
     :page => @page,          :from_address => from_address,
     :from_name => from_name }
    opts[:port] = request.port_string.sub(':','') if request.port_string.present?
    return opts
  end

  ##
  ## CLASS METHODS
  ##

  # rather than include every stylesheet in every request, some stylesheets are
  # only included "as needed". A controller can set a custom stylesheet
  # using 'stylesheet' in the class definition:
  #
  # for example:
  #
  #   stylesheet 'gallery', 'images'
  #   stylesheet 'page_creation', :action => :create
  #
  # They'll be accessible in the class_attribute stylesheets
  #
  # as needed stylesheets are kept in public/stylesheets/as_needed
  #
  def self.stylesheet(*css_files)
    self.stylesheets = merge_requirements(self.stylesheets, *css_files)
  end

  # let controllers require extra javascript
  # for example:
  #
  #   javascript 'wiki_edit', :action => :edit
  #
  # They'll be accessible in the class_attribute javascripts
  #
  def self.javascript(*js_files)
    self.javascripts = merge_requirements(self.javascripts, *js_files)
  end

  def self.merge_requirements(current, *new_files)
    current ||= {}
    options = new_files.extract_options!
    index   = options[:action] || :all
    value   = current[index] || []
    value += new_files
    current.merge index => value.uniq
  end

end
