class LinkRenderer::ModalAjax < LinkRenderer::Ajax
  protected

  def link_options
    # Modalbox content is usually rendered inserting html into the box
    # directly.  So the same should happen on pagination. Otherwise we
    # end up with two xhr request types - one for the initial loading of
    # the modal and one for pagination.
    super.tap do |options|
      options[:data][:update] = 'MB_content'
    end
  end
end
