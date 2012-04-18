#
# All the magic directory constants should live here.
#

dirs = []

# config

dirs << CRABGRASS_CONFIG_DIRECTORY = "#{Rails.root}/config/crabgrass"
CRABGRASS_SECRET_FILE              = "#{CRABGRASS_CONFIG_DIRECTORY}/secret.txt"

# extensions

dirs << EXTENSION_DIRECTORY       = "#{Rails.root}/extensions"
dirs << THEMES_DIRECTORY          = "#{EXTENSION_DIRECTORY}/themes"
dirs << SEARCH_FILTERS_DIRECTORY  = "#{EXTENSION_DIRECTORY}/search_filters"
dirs << LOCALE_OVERRIDE_DIRECTORY = "#{EXTENSION_DIRECTORY}/locales"
dirs << WIDGETS_DIRECTORY         = "#{EXTENSION_DIRECTORY}/widgets"


# plugins

dirs << MODS_DIRECTORY              = "#{EXTENSION_DIRECTORY}/mods"
dirs << PAGES_DIRECTORY             = "#{EXTENSION_DIRECTORY}/pages"
dirs << CRABGRASS_PLUGINS_DIRECTORY = "#{Rails.root}/vendor/crabgrass_plugins"

# tmp

dirs << TMP_DIRECTORY   = "#{Rails.root}/tmp"
dirs << CACHE_DIRECTORY = "#{TMP_DIRECTORY}/cache"

# stylesheets and javascript

dirs << STATIC_JS_SRC_DIR        = "#{Rails.root}/app/assets/javascripts"
dirs << STATIC_JS_DEST_DIR       = "#{Rails.root}/public/static"

# assets

if RAILS_ENV == 'test'
  dirs << ASSET_PRIVATE_STORAGE   = "#{Rails.root}/tmp/private_assets"
  dirs << ASSET_PUBLIC_STORAGE    = "#{Rails.root}/tmp/public_assets"
  dirs << PICTURE_PRIVATE_STORAGE = "#{Rails.root}/tmp/private_pictures"
  dirs << PICTURE_PUBLIC_STORAGE  = "#{Rails.root}/tmp/public_pictures"
  dirs << KEYRING_STORAGE         = "#{Rails.root}/tmp/private_assets/keyrings"
else
  dirs << ASSET_PRIVATE_STORAGE   = "#{Rails.root}/assets"
  dirs << ASSET_PUBLIC_STORAGE    = "#{Rails.root}/public/assets"
  dirs << PICTURE_PRIVATE_STORAGE = "#{Rails.root}/assets/pictures"
  dirs << PICTURE_PUBLIC_STORAGE  = "#{Rails.root}/public/pictures"
  dirs << KEYRING_STORAGE         = "#{Rails.root}/assets/keyrings"
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

