# Page::Finder
#
# Find pages for short urls such as group/title-of-page
# Used from the ContextPagesController.
#
# When page is called we try to find one page and return it.
# If we cannot identify a single page we just return nil for now.

class Page::Finder

  def initialize(context_handle, page_handle, options = {})
    @handle = page_handle
    @context, @group, @user = find_context(context_handle)
    @options = options
  end

  attr_reader :group, :user

  def page
    if handle =~ /[ +](\d+)$/
      # if page handle ends with [:space:][:number:] then find by page id.
      # (the url actually looks like "page-title+52", but pluses are interpreted
      # as spaces). find by id will always return a globally unique page so we
      # can ignore context
      Page.find( $~[1] )
    elsif context
      context.find_page(handle)
    else
      pages = find_pages_with_unknown_context(handle)
      if pages.size == 1
        pages.first
      elsif pages.size > 1
        # for now, we don't support this.
      end
    end
  end

  protected
  attr_reader :handle, :context, :options


  def find_context(name)
    if name
      if name =~ /\ /
        # we are dealing with a committee!
        name = name.sub(' ','+')
      end
      group = Group.find_by_name(name)
      return group, group, nil if group
      user  = User.find_by_login(name)
      return user, nil, user
    end
  end

  def find_pages_with_unknown_context(name)
    Page.paginate_by_path ["name",name], options
  end
end
