#
# defines a one-stop shop for displaying pagination links using the method
# pagination_links().
#
# all the code should use pagination_links() rather than call
# will_paginate() directly.
#
module Common::Ui::PaginationHelper

  protected

#  def letter_pagination_labels
#    $letter_pagination_labels_list ||= ("A".."Z").to_a + ["#"]
#  end

#  def letter_pagination_links(url_opts = {}, pagination_opts = {}, &url_proc)
#    url_proc = method :url_for if url_proc.nil?
#    available_letters = pagination_opts[:available_letters]
#    if available_letters and !available_letters.grep(/^[^a-z]/i).empty?
#      # we have things that are not letters in the mix
#      available_letters << "#"
#    end

#    render  :partial => 'pages/letter_pagination',
#                        :locals => {:letter_labels => letter_pagination_labels,
#                                    :available_letters => pagination_opts[:available_letters],
#                                    :url_proc => url_proc,
#                                    :url_opts => url_opts,
#                                    }
#  end

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
  def pagination_links(things, options={})
    return unless things.respond_to?(:total_pages)

    defaults = {
     :previous_label => ("&laquo; %s" % :pagination_previous.t).html_safe,
     :next_label => ("%s &raquo;" % :pagination_next.t).html_safe,
     :inner_window => 2,
     :outer_window => 0
    }

    if defined? page_search_path
      if xhr_page_search?
        defaults[:renderer] = LinkRenderer::AjaxPages
      else
        defaults[:renderer] = LinkRenderer::Pages
      end
    elsif request.xhr?
      # this is a really bad guess, and should be replaced with a parameter
      defaults[:renderer] = (current_template_format == :html) ?
       LinkRenderer::ModalAjax :
       LinkRenderer::Ajax
    else
      defaults[:renderer] = LinkRenderer::Dispatch
    end
    will_paginate(things, defaults.merge(options))
  end

  def current_template_format
    ## FIXME: this is likely going to break during the next rails upgrade.
    ##   We should figure out a better way to choose the link renderer.
    @renderer.instance_variable_get("@template").mime_type.symbol
  end

  #
  # returns true if the array of things is actually paginated
  #
  def paginated?(things)
    things.respond_to?(:total_entries) && things.total_entries > things.per_page
  end

  #
  # used at the top of a page where you want a little space after the pagination links,
  # but only if there are any pagination links.
  #
  def top_pagination_links(things, options={})
    if paginated?(things)
      content_tag(:div, :class => 'p first') do
        pagination_links(things,options)
      end
    end
  end

  #
  # useful for the bottom of the page.
  #
  def bottom_pagination_links(things, options={})
    if paginated?(things)
      content_tag(:div, :class => 'p last') do
        pagination_links(things,options)
      end
    end
  end
end

