#
# Our CSS is dynamically generated and then statically cached. There are a
# couple ways we could do this: one would be to generate the CSS files when
# the urls are referenced in the html header (ie <stylesheet ... />)
#
# Another method would be to make the stylesheet urls hit a controller, and
# have that controller re-render the stylesheets. This is what we have done
# here. I am not sure which method is better, but this seems to work.
#
# This does not work, however, for destroying the cache. For this, we do
# use the first method: Theme.stylesheet_url(..) will destroy the cached
# sheets in development mode if they need to be re-rendered. It might
# make more sense to combine both the rendering and the destroying in the
# same place. One advantage of the method here is that we can display
# a nice stylesheet specific error message if there is a sass syntax error.
#

class ThemeController < ApplicationController
  include_controllers 'common/always_perform_caching'

  attr_accessor :cache_css
  caches_page :show, if: proc { |ctrl| ctrl.cache_css }

  def show
    if stale?(@theme, file: @file, last_modified: css_last_modified)
      render :show, content_type: 'text/css', formats: [:css]
    end
  rescue Sass::SyntaxError => exc
    self.cache_css = false
    render html: @theme.error_response(exc)
    expire_page name: params[:name], file: params[:file]
  end

  protected

  # don't cache css if '_refresh' is in the theme or stylesheet name.
  # useful for debugging.
  prepend_before_filter :get_theme
  def get_theme
    self.cache_css = true
    [params[:name], *params[:file]].each do |param|
      if param =~ /_refresh/
        param.sub!('_refresh', '')
        self.cache_css = false
      end
    end
    @theme = Crabgrass::Theme[params[:name]]
    @file = File.join(params[:file])
    @theme.clear_cache(@file) unless cache_css
  end

  def css_last_modified
    @css_last_modified ||= [@theme.updated_at, css_updated_at].max
  end
  helper_method :css_last_modified

  def css_updated_at
    Dir.glob('app/stylesheets/**/*').map { |f| File.mtime(f) }.max
  end
end
