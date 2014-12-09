#
# methods and helpers for context and navigation that should
# be available in all controllers.
#

module Common::Application::ContextNavigation


  def self.included(base)
    base.class_eval do
      helper_method :setup_navigation
    end
  end

  protected

  ##
  ## OVERRIDE
  ##

  def setup_navigation(nav)
    return nav
    # this can be implemented by controller subclasses
  end

  #
  # returns the group and the page for a particular context path
  # eg.
  #   entity, page = resolve_context('riseup', 'minutes')
  #
  # This would correspond to: https://we.riseup.net/riseup/minutes
  #
  # currently, i think this is only used by the wiki renderer
  #
  def resolve_context(context_name, page_name, allow_multiple_results=false)

    #
    # Context
    #

    if context_name =~ /\ /
      # we are dealing with a committee!
      context_name.sub!(' ','+')
    end

    group = Group.find_by_name(context_name)
    user  = User.find_by_login(context_name) unless group

    #
    # Page
    #

    if page_name.nil?
      unless group || user
        raise ActiveRecord::RecordNotFound.new
      end
    elsif page_name =~ /[ +](\d+)$/ || page_name =~ /^(\d+)$/
      # if page handle ends with [:space:][:number:] or entirely just numbers
      # then find by page id. (the url actually looks like "my-page+52", but
      # pluses are interpreted as spaces). find by id will always return a
      #  globally unique page so we can ignore context
      page = Page.find( $~[1] )
    elsif group
      # find just pages with the name that are owned by the group
      # no group should have multiple pages with the same name
      page = Page.for_group(group).where(name: name).first
    elsif user and !allow_multiple_results
      page = user.pages.where(name: name).first
    elsif user and allow_multiple_results
      page = user.pages.where(name: name).all
    end

    raise ActiveRecord::RecordNotFound.new unless page

    return [(group||user), page]
  end

end

