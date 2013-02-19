#
# All the magic directory constants should live here.
#

dirs = []

# config

dirs << CRABGRASS_CONFIG_DIRECTORY = "#{RAILS_ROOT}/config/crabgrass"
CRABGRASS_SECRET_FILE              = "#{CRABGRASS_CONFIG_DIRECTORY}/secret.txt"

# extensions

dirs << EXTENSION_DIRECTORY       = "#{RAILS_ROOT}/extensions"
dirs << THEMES_DIRECTORY          = "#{EXTENSION_DIRECTORY}/themes"
dirs << SEARCH_FILTERS_DIRECTORY  = "#{EXTENSION_DIRECTORY}/search_filters"
dirs << LOCALE_OVERRIDE_DIRECTORY = "#{EXTENSION_DIRECTORY}/locales"
dirs << WIDGETS_DIRECTORY         = "#{EXTENSION_DIRECTORY}/widgets"


# plugins

dirs << MODS_DIRECTORY              = "#{EXTENSION_DIRECTORY}/mods"
dirs << PAGES_DIRECTORY             = "#{EXTENSION_DIRECTORY}/pages"
dirs << CRABGRASS_PLUGINS_DIRECTORY = "#{RAILS_ROOT}/vendor/crabgrass_plugins"

# tmp

dirs << TMP_DIRECTORY   = "#{RAILS_ROOT}/tmp"
dirs << CACHE_DIRECTORY = "#{TMP_DIRECTORY}/cache"

# stylesheets and javascript

dirs << STATIC_JS_SRC_DIR        = "#{RAILS_ROOT}/app/assets/javascripts"
dirs << AS_NEEDED_JS_SRC_DIR     = "#{RAILS_ROOT}/app/assets/javascripts/as_needed"
dirs << STATIC_JS_DEST_DIR       = "#{RAILS_ROOT}/public/static"
dirs << AS_NEEDED_JS_DEST_DIR    = "#{RAILS_ROOT}/public/static/as_needed"

# assets

if Rails.env == 'test'
  dirs << ASSET_PRIVATE_STORAGE   = "#{RAILS_ROOT}/tmp/private_assets"
  dirs << ASSET_PUBLIC_STORAGE    = "#{RAILS_ROOT}/tmp/public_assets"
  dirs << PICTURE_PRIVATE_STORAGE = "#{RAILS_ROOT}/tmp/private_pictures"
  dirs << PICTURE_PUBLIC_STORAGE  = "#{RAILS_ROOT}/tmp/public_pictures"
  dirs << KEYRING_STORAGE         = "#{RAILS_ROOT}/tmp/private_assets/keyrings"
else
  dirs << ASSET_PRIVATE_STORAGE   = "#{RAILS_ROOT}/assets"
  dirs << ASSET_PUBLIC_STORAGE    = "#{RAILS_ROOT}/public/assets"
  dirs << PICTURE_PRIVATE_STORAGE = "#{RAILS_ROOT}/assets/pictures"
  dirs << PICTURE_PUBLIC_STORAGE  = "#{RAILS_ROOT}/public/pictures"
  dirs << KEYRING_STORAGE         = "#{RAILS_ROOT}/assets/keyrings"
end

#
# ensure the directories exist
#

require 'fileutils'

dirs.each do |dir|
  unless File.directory?(dir)
    if File.exists?(dir)
      raise 'ERROR: %s is supposed to be a directory, but file already exists' % dir
    else
      FileUtils.mkdir_p(dir)
    end
  end
end

