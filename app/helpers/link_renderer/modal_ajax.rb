class LinkRenderer::ModalAjax < LinkRenderer::Ajax

  protected

  def link_options(page)
    # Modalbox content is usually rendered inserting html into the box
    # directly.  So the same should happen on pagination. Otherwise we end up
    # with two xhr request types - one for the initial loading of the modal and
    # one for pagination.
    options = { url: url_for(page),
      method: :get,
      loading: @template.show_spinner(spinner_id),
      update: 'MB_content' }
  end

end

