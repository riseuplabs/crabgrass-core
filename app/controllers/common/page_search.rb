#
# include this in controllers that let you filter lists of pages
#

module Common::PageSearch

  def self.included(base)
    base.class_eval do
      helper_method :xhr_page_search?
      helper_method :page_search_path
      helper_method :show_filter?
    end
  end

  protected

  #
  # if params[:add] or params[:remove] are set, then this method
  # will take those path segments and apply them to the path object.
  #
  def apply_path_modifiers(path)
    if params[:add]
      add_segment = parse_filter_path(params[:add])
      return path.merge(add_segment)
    elsif params[:remove]
      remove_segment = parse_filter_path(params[:remove])
      return path.remove(remove_segment)
    else
      return path
    end
  end

  #
  # returns a ParsedPath using either params[:path] or params[:filter].
  #
  # params[:path] will be an array that is set by a wildcard in routes.rb.
  #
  # params[:filter] is a path that is added to the request by the
  # javascript function FilterPath.encode() based on the window.location.hash.
  #
  # The encoding of :filter and :path are different, so we need to call different
  # methods to convert them to a ParsedPath.
  #
  def parsed_path
    if params[:path].present?
      parse_filter_path(params[:path])
    elsif params[:filter]
      parse_hash_filter_path(params[:filter])
    else
      parse_filter_path([])
    end
  end

  #
  # controllers that include this mixin should redefine this to true if they
  # want the page search to not be ajax based.
  #
  def xhr_page_search?
    true
  end

  #
  # the page search code relies on this being defined by controllers that
  # include this mixin.
  #
  def page_search_path(*args)
    raise 'you must define page_search_path()'
  end

  #
  # controllers including this mixin may define this to control which
  # filters are shown.
  #
  def show_filter?(filter)
    true
  end

end

