module Common::Ui::TextHelper
  # convert greencloth marktup to html
  def to_html(str)
    ## FIXME: add 'html_safe' in GreenCloth's to_html instead of here
    str.present? ? GreenCloth.new(str).to_html.html_safe : ''
  end
end
