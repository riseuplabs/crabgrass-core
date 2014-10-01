module Common::Page::UrlHelper

  def sort_page_items_url(*args)
    options = args.extract_options!
    if @page.present?
      options.reverse_merge! page_id: @page.id, controller: @page.controller
    end
    args << options
    super
  end
end
