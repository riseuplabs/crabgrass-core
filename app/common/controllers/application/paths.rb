#
# Here lies some path helpers that are not defined by routes and should
# be available to all views and controllers. 
#

module Common::Controllers::Application::Paths

  def self.included(base)
    base.class_eval do
      helper_method :entity_path
      helper_method :page_path
      helper_method :page_url
      helper_method :page_xpath
      helper_method :page_xurl
      helper_method :new_page_path
      helper_method :me_path
      helper_method :me_url
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

  def entity_url(entity)
    urlize entity_path(entity)
  end

  ##
  ## PAGE PATHS
  ##

  # for a couple reasons, page creation is handled by a separate controller. 
  # using 'new_page_create_path' is just awkward, so we alias it here.
  def new_page_path(options={})
    create_page_path(options)
  end

  # The default url helpers based on the routes will not create correct links.
  # They link to the super class Pages::BaseController, ie /pages/:id. 
  # That is no good. We want page paths in these forms:
  #
  # (1) pretty -- /:context/:page_name_or_id/:action/:id
  # (2) direct -- /pages/:controller/:action/:page_id
  #
  # We use the direct form when pretty doesn't matter, like ajax. The direct
  # form bypasses the dispatcher.
  #

  # PRETTY PAGE PATHS

  def page_path(page, options={})
    if options[:action] == 'show' and not options[:id]
      options.delete(:action)
    end

    # if a controller is set, encode it with the action (this allows our context
    # routes to still work but allows pages to have multiple controllers). 
    action = [options.delete(:controller), options.delete(:action)].compact.join('-')

    if page.owner_name
      path = [page.owner_name, page.name_url]
    elsif page.created_by_id
      # we can't use page.name_url, because there might be multiple pages
      # with the same name created by the same user.
      path = [page.created_by_login, page.friendly_url]
    end
    path << action
    path << options.delete(:id)
    '/' + path.select(&:any?).join('/') + build_query_string(options)
  end

  def page_url(page, options={})
    urlize page_path(page, options)
  end

  # DIRECT PAGE PATHS

  def page_xpath(page, options={})
    controller = '/' + [page.controller, options.delete(:controller)].compact.join('_')
    options[:action] ||= 'index'
    '/pages' + [controller,page.id,options.delete(:action)].join('/') + build_query_string(options)
  end

  def page_xurl(page, options={})
    urlize page_xpath(page,options)
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

