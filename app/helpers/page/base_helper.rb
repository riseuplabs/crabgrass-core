#
# available to all page controllers derived from base.
#
module Page::BaseHelper
  protected

  ##
  ## MISC HELPERS
  ##

  def page_tabs(options = {})
    options.reverse_merge! id: 'page_tabs',
                           class: 'reloadable'
    formy(:tabs, options) do |f|
      yield(f)
    end
  end
end
