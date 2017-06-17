# Page::Finder
#
# Find pages for short urls such as group/title-of-page
# Used from the ContextPagesController.
#
# When page is called we try to find one page and return it.
# First of all we identify the context of the page as a group or a user.
# If we cannot identify the context we return nil.
#
# We used to try to find pages even if we could not identify the context.
# This is currently broken in production. I'm not sure if it was ever used at
# scale. So I removed this to reduce complexity.

class Page::Finder

  def initialize(context_handle, page_handle)
    @handle = page_handle
    @context, @group, @user = find_context(context_handle)
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
    end
  end

  protected
  attr_reader :handle, :context


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

end
