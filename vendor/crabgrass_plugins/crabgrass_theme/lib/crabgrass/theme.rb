##
## Theme - A set of configured customizations to the appearance of crabgrass
##


module Crabgrass
  class Theme
  end
end

unless defined?(info)
  def info(str,lvl=1)
    puts str
  end
end

%w[renderer cache loader options navigation_item navigation_definition].each do |file|
  require_relative "theme/#{file}"
end

module Crabgrass
  class Theme

    include Crabgrass::Theme::Renderer
    include Crabgrass::Theme::Cache
    include Crabgrass::Theme::Loader
    include Crabgrass::Theme::ColumnCalculator

    THEME_ROOT = Rails.root.join('extensions', 'themes')  # where theme configs live
    SASS_ROOT  = Rails.root.join('app', 'stylesheets')    # where the sass source files live
    CSS_ROOT   = Rails.root.join('public', 'theme')       # where the rendered css files live
    CORE_CSS_SHEET = 'screen'

    attr_reader :directory, :public_directory, :name, :data
    attr_reader :navigation
    attr_reader :parent             # the parent of the theme data
    attr_reader :navigation_parent  # the parent of the navigation data

    @@themes = {}

    # for the theme to work, this controller must be set.
    # crabgrass sets it in a before_filter common to call controllers.
    # TODO: will this be a problem with multiple threads?
    attr_accessor :controller

    def initialize(theme_name)
      @directory  = Theme::theme_directory(theme_name)
      @name       = File.basename(@directory) rescue nil
      @public_directory = CSS_ROOT + @name
      @data       = nil
      @style      = nil
      @controller = nil
    end

    ##
    ## PUBLIC CLASS METHODS
    ##

    #
    # grabs a theme by name, loading if necessary. In production mode, theme is
    # kept loaded in the memory until the app is restarted. In development mode,
    # the theme is reloaded each time the theme configuration changes.
    #
    # This auto-reloading of stale theme configs is triggered by a call to
    # Theme.stylesheet_url(), which is typically called in the view.
    # Someday, this might be a problem and we might need to trigger manually
    # a reload if needed.
    #
    # usage:
    #   Theme['default'] => <theme>
    #
    def self.[](theme_name)
      @@themes[theme_name] ||= Loader::create_and_load(theme_name)
    end

    # return true if the theme's directory exists.
    def self.exists?(theme_name)
      return if theme_name.blank?
      File.directory? Theme::theme_directory(theme_name)
    end

    ##
    ## PUBLIC INSTANCE METHODS
    ##

    #
    # access theme configuration variable.
    # eg current_theme[:border_width]
    #
    def [](key)
      @data[key.to_sym]
    end

    #
    # alternate method of accessing a theme configuration variable.
    # eg current_theme.border_width
    #
    def method_missing(key)
      @data[key.to_sym]
    end

    #
    # returns an integer representation of a theme configuration variable.
    #
    def int_var(key)
      if self[key].present?
        self[key].gsub(/[^0-9]/,'').to_i
      else
        0
      end
    end

    # used for theme inheritance.
    # a deep clone is not needed, because @data is just a shallow hash, even
    # though the theme definition files seem all nesty.
    def data_copy
      @data.dup
    end

    ##
    ## THEME URLS
    ##

    # returns an absolute url path, specific to this theme, given a sheet name
    # e.g.
    #   stylesheet_url('screen') => /theme/default/screen.css

    def stylesheet_url(sheet_name)
      clear_cache_if_needed(sheet_name)
      File.join('','theme', @name, sheet_name + '.css')
    end

    # given a resource or file, returns an absolute url path that
    # points to the correct url in the theme's public image directory
    # a named resouce:
    #   url('favicon') => /theme/default/images/my_favicon.png
    # a file:
    #   url('background.jpg') => /theme/default/images/background.jpg
    # in general, named resources should be used instead of file names
    # in order to allow themes to selectively override images.
    def url(image_name)
      filename = @data[image_name.to_sym] || image_name
      File.join('','theme', @name, 'images', filename)
    end

    private

    def self.theme_directory(theme_name)
      THEME_ROOT + theme_name
    end

    #def self.theme_loaded?(theme_name)
    #  not @@themes[theme_name].nil?
    #end

    #def self.needs_reloading?(theme_name)
    #  Cache::directory_changed_since?(theme_directory(theme_name), @@theme_timestamps[theme_name])
    #end

  end
end

