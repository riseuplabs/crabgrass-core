#
# defines a one-stop shop for displaying pagination links using the method
# pagination_links().
#
# all the code should use pagination_links() rather than call
# will_paginate() directly.
#
module Common::Ui::PaginationHelper
  protected

  #
  # Default pagination link options:
  #
  #   :class        => 'pagination',
  #   :previous_label   => '&laquo; Previous',
  #   :next_label   => 'Next &raquo;',
  #   :inner_window => 4, # links around the current page
  #   :outer_window => 1, # links around beginning and end
  #   :separator    => ' ',
  #   :param_name   => :page,
  #   :params       => nil,
  #   :renderer     => 'WillPaginate::ViewHelper::LinkRenderer',
  #   :page_links   => true,    # when false, only previous/next links are rendered
  #   :container    => true
  #
  def pagination_links(things, options = {})
    return unless paginated?(things)

    defaults = {
      previous_label: format('&laquo; %s', :previous.t).html_safe,
      next_label: format('%s &raquo;', :next.t).html_safe,
      inner_window: 2,
      outer_window: 0,
      renderer: pagination_link_renderer
    }
    will_paginate(things, defaults.merge(options))
  end

  #
  # returns true if the array of things is actually paginated
  #
  def paginated?(things)
    things.respond_to?(:total_entries) && things.total_entries > things.per_page
  end
end
