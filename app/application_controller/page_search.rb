module ApplicationController::PageSearch

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
  # returns a parsed path using either params[:path] or params[:filter].
  #
  # params[:path] will be an array that is set by a wildcard in routes.rb.
  #
  # params[:filter] is a path that is added to the request by the
  # javascript function FilterPath.encode() based on the window.location.hash.
  #
  # The encoding of :filter and :path are different, so we need to call different
  # methods to convert them to a ParsedPath.
  #
  def page_search_path
    if params[:path].any?
      parse_filter_path(params[:path])
    elsif params[:filter]
      parse_hash_filter_path(params[:filter])
    else
      parse_filter_path([])
    end
  end

end

