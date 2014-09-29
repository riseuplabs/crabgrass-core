#
# Here lies some path helpers that are not defined by routes and should
# be available to all views and controllers.
#

module Common::Application::Paths

  def self.included(base)
    base.class_eval do
      helper_method :entity_path
      helper_method :entity_url
      helper_method :user_path
      helper_method :user_url
      helper_method :group_path
      helper_method :group_url
      helper_method :direct_group_path

      helper_method :page_path
      helper_method :page_url
      helper_method :page_xpath
      helper_method :page_xurl
      helper_method :new_page_path
      helper_method :create_page_path

      helper_method :me_path
      helper_method :me_url

      helper_method :user_avatar_path
      helper_method :build_query_string
    end
  end

  protected

  ##
  ## ENTITY PATHS
  ##

  def entity_path(entity)
    if entity.is_a? String
      "/"+name
    else
      "/"+entity.name
    end
  end
  alias_method :user_path, :entity_path
  alias_method :group_path, :entity_path

  def entity_url(entity)
    urlize entity_path(entity)
  end
  alias_method :user_url, :entity_url
  alias_method :group_url, :entity_url

  #
  # allow direct paths that bypass the dispatcher.
  #
  def direct_group_path(group,options={})
    "/groups/" + group.name + build_query_string(options)
  end

  ##
  ## PAGE PATHS
  ##

  #
  # for a couple reasons, page creation is handled by a separate controller.
  # this is not a resource route, but we create paths methods as if it was for consistency.
  #

  def new_page_path(options={})
    options[:action] = 'new'
    options[:owner] ||= params[:owner] || :me
    custom_create_path(options) || page_creation_path(options)
  end

  def create_page_path(options={})
    options[:action] = 'create'
    options[:owner] ||= params[:owner]
    custom_create_path(options) || page_creation_path(options)
  end

  #
  # if page definition has a custom constroller, return a path for it.
  # otherwise, returns nil and modifies options hash as needed.
  #
  def custom_create_path(options={})
    if (page_type = options.delete(:page_type)).present?
      if (controller = page_type.definition.creation_controller).present?
        return "/pages/#{controller}/#{options[:action]}/#{options[:owner]}"
      else
        options[:type] = page_type.url
        return nil
      end
    end
  end

  #
  # The default url helpers based on the routes will not create correct links.
  # They link to the super class Pages::BaseController, ie /pages/:id.
  # That is no good. We want page paths in these forms:
  #
  # (1) pretty -- page_path and page_url
  #               /:context/:page/:action/:id
  #               /:context/:page/:controller/:action/:id
  #
  # (2) direct -- page_item_url and friends
  #               restful routes to
  #               /pages/:page_id/:controller/:id
  #               (restful actions so GET without :id -> index etc.)
  #
  # We use the direct form when pretty doesn't matter, like ajax. The direct
  # form bypasses the dispatcher and so is slightly faster and less prone to errors.
  #
  # :controller can be passed in options arg in one of two ways:
  #
  #   as a symbol -- e.g. giving :history as the controller will correspond to
  #                  AssetPageHistoryController if @page is an Asset.
  #
  #   as a string -- the full name of the controller, ie 'asset_page_history'
  #

  #
  # pretty page path
  #
  def page_path(page, options={})

    # (1) context
    if page.owner_name
      path = [page.owner_name, page.name_url]
    elsif page.created_by_login
      # we can't use page.name_url, because there might be multiple pages
      # with the same name created by the same user.
      path = [page.created_by_login, page.friendly_url]
    else
      # there is some data corruption. not sure what to do.
      path = ['page', page.friendly_url]
    end

    # (2) controller
    controller = options.delete(:controller)
    if controller and Rails.env == 'development' and controller.is_a?(Symbol)
       cntr = page.controller + '_' + controller.to_s
       unless page.controllers.include?(cntr)
        raise 'controller %s not defined for page type %s' % [cntr, page.class.name]
      end
    end
    path << controller

    # (3) action
    action = options.delete(:action)
    if action == 'show' and !options[:id]
      action = nil
    end
    path << action

    # (4) id
    path << options.delete(:id)

    return ('/' + path.select(&:present?).join('/') + build_query_string(options))
  end

  def page_url(page, options={})
    urlize page_path(page, options)
  end

  ##
  ## ME
  ##

  def me_path(*args)
    me_home_path(*args)
  end

  def me_url(*args)
    me_home_url(*args)
  end

  def user_avatar_path(*args)
    me_avatar_path(args.last)
  end

  ##
  ## UTILITY
  ##

  #
  # lifted from active_record's routing.rb
  #
  # Build a query string from the keys of the given hash. If +only_keys+
  # is given (as an array), only the keys indicated will be used to build
  # the query string. The query string will correctly build array parameter
  # values.
  #
  def build_query_string(hash, only_keys=nil)
    elements = []

    only_keys ||= hash.keys

    only_keys.each do |key|
      value = hash[key] or next
      key = CGI.escape key.to_s
      if value.class == Array
        key <<  '[]'
      else
        value = [ value ]
      end
      value.each { |val| elements << "#{key}=#{CGI.escape(val.to_param.to_s)}" }
    end

    query_string = "?#{elements.join("&")}" unless elements.empty?
    query_string || ""
  end

  private

  def urlize(path)
    request.protocol + request.host_with_port + path
  end
end

