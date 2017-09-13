module Page::PopupHelper
  def page_popup_form(mode, options = {}, &block)
    options.reverse_merge! url: page_share_path(@page, mode: mode),
                           id: "#{mode}_page_form",
                           onsubmit: show_spinner('popup'),
                           method: 'put',
                           remote: true
    form_tag options.delete(:url), options, &block
  end
end
