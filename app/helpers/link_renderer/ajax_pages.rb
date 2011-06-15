#
# This is a link renderer for page lists that are ajax based.
# 
# For example:
#   with url: me/pages#/public/page/3
#   then: the link to 'next' will submit an ajax request with {:add => '/page/4'}
#
class LinkRenderer::AjaxPages < WillPaginate::LinkRenderer

  def page_link(page, text, attributes = {})
    options = {
      :url => @template.page_search_path(:add => "/page/#{page}"),
      :with => 'FilterPath.encode()',
      :method => :get,
      :loading => @template.show_spinner(spinner_id)
    }
    @template.link_to_remote(text, options, attributes)
  end

  def page_span(page, text, attributes = {})
    @template.content_tag :span, text, attributes
  end

  def to_html
    # we want the spinner inside the pagination container div, so we override the
    # default container and define one here:
    @template.content_tag :div, :class => 'pagination' do
      super + ' ' + @template.spinner(spinner_id)
    end
  end

  def spinner_id
    # eg, if we are paginating user_participations, results in spinners with
    # id => 'pagination_user_participation_spinner'
    'pagination_' + @collection.first.class.name.underscore
  end

end

